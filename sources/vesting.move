module dexlyn_tokenomics::vesting {

    use std::bcs::to_bytes;
    use std::fixed_point32::{Self, FixedPoint32};
    use std::option::{Self, Option};
    use std::signer::address_of;
    use std::vector;
    use aptos_std::math64::min;
    use aptos_std::simple_map::{Self, SimpleMap};

    use dexlyn_coin::dxlyn_coin;
    use supra_framework::event;
    use supra_framework::object::{Self, ExtendRef};
    use supra_framework::primary_fungible_store;
    use supra_framework::timestamp;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                CONSTANTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Deployer address
    const CA: address = @dexlyn_tokenomics;

    /// Vesting resource account creation seed
    const VESTING_RESOURCE_SEED: vector<u8> = b"VESTING";

    /// Vesting Admin seed
    const VESTING_ADMIN_SEED: vector<u8> = b"VESTING_ADMIN";

    /// It represents contract is in active state
    const CONTRACT_STATE_ACTIVE: u8 = 1;

    /// It represents contract has been terminated
    const CONTRACT_STATE_TERMINATED: u8 = 2;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                ERRORS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Vesting schedule vector is invalid (e.g. empty or contains zero values).
    const ERROR_INVALID_SCHEDULE_VECTOR: u64 = 101;

    /// Vesting period duration must be greater than zero.
    const ERROR_INVALID_PERIOD_DURATION: u64 = 102;

    /// Vesting numerators are invalid (e.g. empty, zero-valued, or inconsistent).
    const ERROR_INVALID_NUMERATORS: u64 = 103;

    /// Denominator must be greater than or equal to the sum of numerators.
    const ERROR_INVALID_DENOMINATOR: u64 = 104;

    /// Vesting shareholders are invalid (e.g. empty).
    const ERROR_INVALID_SHAREHOLDER: u64 = 105;

    /// Address is not match with deployer
    const ERROR_NOT_DEPLOYER: u64 = 106;

    /// Grant must be greater then zero
    const ERROR_INVALID_GRANT: u64 = 107;

    /// Admin is already exists
    const ERROR_ADMIN_STORE_EXISTS: u64 = 108;

    /// Shareholder is not exists
    const ERROR_SHAREHOLDER_NOT_EXISTS: u64 = 109;

    /// Contract not found
    const ERROR_CONTRACT_NOT_FOUND: u64 = 110;

    /// Cannot vest before the cliff period has been reached.
    const ERROR_CLIFF_PERIOD_NOT_REACHED: u64 = 111;

    /// Shareholders must be unique
    const ERROR_NO_DUPLICATE_SHAREHOLDER: u64 = 112;

    /// Contract is terminated
    const ERROR_TERMINATED_CONTRACT: u64 = 113;

    /// Caller is not the admin of the contract.
    const ERROR_NOT_ADMIN: u64 = 114;

    /// Contract is not terminated
    const ERROR_CONTRACT_STILL_ACTIVE: u64 = 115;

    /// Insufficient balance
    const ERROR_INSUFFICIENT_BALANCE: u64 = 116;

    /// Vesting start time must be greater than the current time
    const ERROR_INVALID_START_TIME: u64 = 117;

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                EVENTS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    #[event]
    /// Emitted when a new vesting contract is created.
    struct CreateVestingContractEvent has drop, store {
        grant_amount: u64,
        withdrawal_address: address,
        vesting_contract: address
    }

    #[event]
    /// Emitted when tokens are vested for a shareholder.
    struct VestEvent has drop, store {
        admin: address,
        shareholder: address,
        vesting_contract: address,
        period_vested: u64
    }

    #[event]
    /// Emitted when tokens are withdrawn from the vesting contract.
    struct AdminWithdrawEvent has drop, store {
        admin: address,
        vesting_contract_address: address,
        amount: u64
    }

    #[event]
    /// Emitted when shareHolder removed from the vesting contract.
    struct ShareHolderRemovedEvent has drop, store {
        shareholder: address,
        beneficiary: Option<address>,
        amount: u64
    }

    #[event]
    /// Emitted when a user contribute tokens into the vesting contract.
    struct ContributeEvent has drop, store {
        user: address,
        amount: u64,
        vesting_store: address,
    }

    #[event]
    /// Emitted when the vesting contract has been terminated by the admin.
    struct TerminateEvent has drop, store {
        admin: address,
        vesting_contract_address: address
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                STATES
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    struct VestingSchedule has key, store, drop, copy {
        // The last fraction repeats until the full amount is vested.
        // Example: [1/24, 1/24, 1/48] means the first two months vest 1/24 each, then 1/48 monthly until complete.
        // Fractions use u32/u32 precision (FixedPoint32).
        /// Vesting schedule defined as a list of per-period fractions (e.g., [1/24, 1/24, 1/48]).
        schedules: vector<FixedPoint32>,

        /// Timestamp when vesting begins.
        start_timestamp_secs: u64,

        /// Duration of each vesting period in seconds (e.g., 1 month).
        period_duration: u64,

        // Last vesting period, 1-indexed. For example if 2 months have passed, the last vesting period,
        // if distribution was requested, would be 2. Default value is 0 which means there have been no vesting periods yet.
        /// Last vesting period
        last_vested_period: u64
    }

    struct VestingRecord has copy, store, drop {
        init_amount: u64,
        left_amount: u64,
        last_vested_period: u64
    }

    struct VestingStore has key {
        admin: address,
        extendRef: ExtendRef,
        vesting_contracts: vector<address>,
        // Used to create resource accounts for new vesting contracts so there's no address collision.
        nonce: u64
    }

    struct VestingContract has key {
        state: u8,
        admin: address,
        beneficiaries: SimpleMap<address, address>,
        /// `[shareholder_address]: VestingRecord`
        shareholders: SimpleMap<address, VestingRecord>,
        vesting_schedule: VestingSchedule,
        /// A address that withdraw back all the funds
        /// if the admin ends the vesting for a specific
        /// account or terminates the entire vesting contract.
        withdrawal_address: address,
        extendRef: ExtendRef
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                CONSTRUCTOR FUNCTION
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Initialize admin store with only developer
    fun init_module(admin: &signer) {
        let constructorRef = &object::create_named_object(admin, VESTING_ADMIN_SEED);
        let extendRef = object::generate_extend_ref(constructorRef);
        let obj_signer = &object::generate_signer_for_extending(&extendRef);

        move_to(
            obj_signer,
            VestingStore {
                admin: address_of(admin),
                nonce: 0,
                extendRef,
                vesting_contracts: vector::empty<address>(),
            }
        );
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                ENTRY FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    /// Allows a user to contribute tokens to the vesting contract.
    ///
    /// The contributed tokens are transferred from the user's account
    /// into the vesting store for future allocation or vesting.
    ///
    /// # Arguments
    /// * `user` - The signer contributing tokens.
    /// * `amount` - The number of tokens to contribute.
    public entry fun contribute(user: &signer, amount: u64) {
        let dxlyn_metadata = dxlyn_coin::get_dxlyn_asset_metadata();
        let user_addr = address_of(user);
        let balance = primary_fungible_store::balance(
            user_addr, dxlyn_metadata
        );

        // Must be not zero
        assert!(balance > 0, ERROR_INSUFFICIENT_BALANCE);
        let store_addr = get_vesting_store_address();

        primary_fungible_store::transfer(
            user,
            dxlyn_metadata,
            store_addr,
            amount
        );

        event::emit(
            ContributeEvent {
                user: user_addr,
                amount,
                vesting_store: store_addr,
            }
        );
    }

    /// Initializes a vesting contract with specified shareholder allocations and a vesting schedule.
    ///
    /// # Parameters
    /// - `admin`: Signer creating and managing the contract.
    /// - `shareholders`: List of beneficiary addresses.
    /// - `shares`: Corresponding share amounts for each beneficiary.
    /// - `numerators`: Fractions of the total vesting schedule for each period (used with `denominator`).
    /// - `denominator`: Common denominator for all vesting fractions.
    /// - `start_timestamp_secs`: Vesting start time (in seconds since UNIX epoch).
    /// - `period_duration`: Duration of each vesting period (in seconds).
    /// - `withdrawal_address`: Address authorized to withdraw vested funds.
    public entry fun create_vesting_contract_with_amounts(
        admin: &signer,
        shareholders: vector<address>,
        shares: vector<u64>,
        numerators: vector<u64>,
        denominator: u64,
        start_timestamp_secs: u64,
        period_duration: u64,
        withdrawal_address: address
    ) acquires VestingStore
    {
        // Validate args
        validate_args(
            period_duration,
            denominator,
            numerators,
            shareholders,
            shares,
            start_timestamp_secs
        );

        let vesting_store_addr = get_vesting_store_address();
        let vesting_store = borrow_global_mut<VestingStore>(vesting_store_addr);
        assert!(vesting_store.admin == address_of(admin), ERROR_NOT_ADMIN);

        let store_admin = &object::generate_signer_for_extending(&vesting_store.extendRef);

        // Generated the duration ratio
        let schedules = vector::map_ref(
            &numerators,
            |numerator| { fixed_point32::create_from_rational(*numerator, denominator) }
        );
        assert!(!vector::is_empty(&schedules), ERROR_INVALID_SCHEDULE_VECTOR);
        assert!(
            fixed_point32::get_raw_value(*vector::borrow(&schedules, 0)) > 0,
            ERROR_INVALID_SCHEDULE_VECTOR
        );

        let vesting_schedule = VestingSchedule {
            schedules,
            last_vested_period: 0,
            period_duration,
            start_timestamp_secs
        };

        let grant_amount = 0;
        let shareholders_map = simple_map::create<address, VestingRecord>();

        vector::for_each_reverse(
            shares,
            |amount| {
                let shareholder = vector::pop_back(&mut shareholders);
                assert!(
                    !simple_map::contains_key(&shareholders_map, &shareholder),
                    ERROR_NO_DUPLICATE_SHAREHOLDER
                );
                simple_map::upsert(
                    &mut shareholders_map,
                    shareholder,
                    VestingRecord {
                        init_amount: amount,
                        left_amount: amount,
                        last_vested_period: vesting_schedule.last_vested_period
                    }
                );

                grant_amount = grant_amount + amount;
            }
        );

        assert!(grant_amount > 0, ERROR_INVALID_GRANT);

        let extendRef = create_vesting_contract_account(store_admin, vesting_store);
        let res_signer = &object::generate_signer_for_extending(&extendRef);
        let res_addr = address_of(res_signer);

        // Transfer vesting to resource address
        primary_fungible_store::transfer(
            store_admin,
            dxlyn_coin::get_dxlyn_asset_metadata(),
            res_addr,
            grant_amount
        );

        vector::push_back(&mut vesting_store.vesting_contracts, res_addr);

        let store_admin_addr = address_of(store_admin);
        move_to(
            res_signer,
            VestingContract {
                state: CONTRACT_STATE_ACTIVE,
                admin: store_admin_addr,
                withdrawal_address,
                shareholders: shareholders_map,
                beneficiaries: simple_map::create<address, address>(),
                extendRef,
                vesting_schedule
            }
        );

        event::emit(
            CreateVestingContractEvent {
                grant_amount,
                withdrawal_address,
                vesting_contract: res_addr
            }
        );
    }

    public entry fun vest(contract_address: address) acquires VestingContract
    {
        assert!(exists<VestingContract>(contract_address), ERROR_CONTRACT_NOT_FOUND);

        let contract = borrow_global_mut<VestingContract>(contract_address);
        assert!(contract.state == CONTRACT_STATE_ACTIVE, ERROR_TERMINATED_CONTRACT);

        let vesting_starts_at = contract.vesting_schedule.start_timestamp_secs;
        let vesting_cliff = contract.vesting_schedule.period_duration;

        // Vest only after the current time exceeds vesting_starts_at + vesting_cliff
        if (timestamp::now_seconds() >= vesting_starts_at + vesting_cliff) {
            let addresses = simple_map::keys(&contract.shareholders);
            while (vector::length(&addresses) > 0) {
                let addr = vector::pop_back(&mut addresses);
                vesting_internal(contract_address, contract, addr);
            };

            // Terminate contract once the contract balance became zero.
            let contract_balance = dxlyn_coin::balance_of(contract_address);
            if (contract_balance == 0) {
                set_terminate_vesting_contract(contract_address, contract);
            }
        }
    }

    /// Vests tokens for a specific shareholder according to the vesting schedule.
    ///
    /// # Augments
    /// - `contract_address`: The address where the `VestingContract` resource is stored.
    /// - `shareholder_address`: The address of the shareholder whose tokens are to be vested.
    public entry fun vest_individual(
        contract_address: address, shareholder_address: address
    ) acquires VestingContract
    {
        assert!(exists<VestingContract>(contract_address), ERROR_CONTRACT_NOT_FOUND);

        let contract = borrow_global_mut<VestingContract>(contract_address);
        assert!(contract.state == CONTRACT_STATE_ACTIVE, ERROR_TERMINATED_CONTRACT);

        let vesting_starts_at = contract.vesting_schedule.start_timestamp_secs;
        let vesting_cliff = contract.vesting_schedule.period_duration;

        // Throws Error if vesting hasn't started yet.
        assert!(
            timestamp::now_seconds() >= vesting_starts_at + vesting_cliff,
            ERROR_CLIFF_PERIOD_NOT_REACHED
        );

        vesting_internal(contract_address, contract, shareholder_address);

        // Terminate contract once the contract balance became zero.
        let contract_balance = dxlyn_coin::balance_of(contract_address);
        if (contract_balance == 0) {
            set_terminate_vesting_contract(contract_address, contract);
        }
    }

    /// Terminates the vesting contract and transfers all remaining funds
    /// back to the designated withdrawal address.
    ///
    /// # Arguments
    /// * `admin` - The signer authorized to terminate the contract.
    /// * `contract` - The address where the `VestingContract` resource is stored.
    public entry fun terminate_vesting_contract(
        admin: &signer, contract: address
    ) acquires VestingContract, VestingStore
    {
        // Vest pending amounts before termination
        // Contract must be active before terminate and it already handled in `vest` function
        vest(contract);

        let res = borrow_global_mut<VestingContract>(contract);

        // Only admin can terminate the contract
        assert_admin(address_of(admin));

        // Set each shareholder's `left_amount` to 0
        let shareholders_address = simple_map::keys(&res.shareholders);
        vector::for_each_ref(
            &shareholders_address,
            |shareholder| {
                let shareholder_amount =
                    simple_map::borrow_mut(
                        &mut res.shareholders, shareholder
                    );
                shareholder_amount.left_amount = 0;
            },
        );

        set_terminate_vesting_contract(contract, res);
    }

    /// Withdraws all remaining funds to the contract's withdrawal address.
    ///
    /// This function can only be called after the vesting contract has been terminated.
    ///
    /// # Arguments
    /// * `admin` - The signer authorized to perform the withdrawal.
    /// * `contract` - The address where the `VestingContract` resource is stored.
    public entry fun admin_withdraw(
        admin: &signer,
        contract: address
    ) acquires VestingContract, VestingStore
    {
        let res = borrow_global<VestingContract>(contract);
        assert!(
            res.state == CONTRACT_STATE_TERMINATED,
            ERROR_CONTRACT_STILL_ACTIVE,
        );

        // Only admin can terminate the contract
        assert_admin(address_of(admin));

        let dxlyn_metadata = dxlyn_coin::get_dxlyn_asset_metadata();
        let contract_balance = primary_fungible_store::balance(
            contract, dxlyn_metadata
        );

        // Balance must be not zero
        assert!(contract_balance > 0, ERROR_INSUFFICIENT_BALANCE);

        let vesting_signer = object::generate_signer_for_extending(&res.extendRef);

        // Transfer store admin
        primary_fungible_store::transfer(
            &vesting_signer,
            dxlyn_metadata,
            res.withdrawal_address,
            contract_balance
        );

        event::emit(
            AdminWithdrawEvent {
                admin: res.admin,
                vesting_contract_address: contract,
                amount: contract_balance
            },
        );
    }

    /// Removes a shareholder from the vesting contract, revoking their allocation.
    ///
    /// This function can only be called by the contract admin.
    ///
    /// # Example
    /// If a shareholder is flagged as suspicious or no longer eligible, the admin can remove them.
    ///
    /// # Arguments
    /// * `admin` - The signer authorized to perform the removal.
    /// * `contract` - The address where the `VestingContract` resource is stored.
    /// * `shareholder` - The address of the shareholder to be removed.
    public entry fun remove_shareholder(
        admin: &signer,
        contract: address,
        shareholder: address
    ) acquires VestingContract, VestingStore
    {
        assert_admin(address_of(admin));

        let res = borrow_global_mut<VestingContract>(contract);
        assert!(res.state == CONTRACT_STATE_ACTIVE, ERROR_TERMINATED_CONTRACT);

        let shareholders = &mut res.shareholders;
        assert!(
            simple_map::contains_key(
                shareholders,
                &shareholder,
            ),
            ERROR_SHAREHOLDER_NOT_EXISTS,
        );

        let shareholder_amount =
            simple_map::borrow(shareholders, &shareholder).left_amount;
        let dxlyn_metadata = dxlyn_coin::get_dxlyn_asset_metadata();

        let res_signer = &object::generate_signer_for_extending(&res.extendRef);
        primary_fungible_store::transfer(
            res_signer,
            dxlyn_metadata,
            res.withdrawal_address,
            shareholder_amount
        );

        event::emit(
            AdminWithdrawEvent {
                admin: res.admin,
                vesting_contract_address: contract,
                amount: shareholder_amount
            },
        );

        // remove `shareholder_address`` from `vesting_contract.shareholders`
        let (_, shareholders_vesting) =
            simple_map::remove(shareholders, &shareholder);

        // remove `shareholder_address` from `vesting_contract.beneficiaries`
        let beneficiary = option::none();
        let shareholder_beneficiaries = &mut res.beneficiaries;

        // Not all shareholders have their beneficiaries, so before removing them, we need to check if the beneficiary exists
        if (simple_map::contains_key(shareholder_beneficiaries, &shareholder)) {
            let (_, shareholder_beneficiary) =
                simple_map::remove(shareholder_beneficiaries, &shareholder);
            beneficiary = option::some(shareholder_beneficiary);
        };

        event::emit(
            ShareHolderRemovedEvent {
                shareholder,
                beneficiary,
                amount: shareholders_vesting.left_amount
            },
        );
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                               VIEW FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    #[view]
    /// Returns the vesting store object address.
    public fun get_vesting_store_address(): address {
        object::create_object_address(&CA, VESTING_ADMIN_SEED)
    }

    #[view]
    /// Returns the vesting schedule details of a given contract.
    ///
    /// # Arguments
    /// * `contract` - The address of the vesting contract.
    ///
    /// # Returns
    /// A tuple containing:
    /// * `withdrawal_address` - Address authorized to withdraw vested tokens.
    /// * `admin` - Address of the contract administrator.
    /// * `period_duration` - Duration (in seconds) of each vesting period.
    /// * `last_vested_period` - The index of the last vested period.
    /// * `state` - The state of the contract (1 , 2).
    public fun get_vesting_schedule(
        contract: address
    ): (address, address, u64, u64, u8) acquires VestingContract
    {
        let contract_data = borrow_global<VestingContract>(contract);
        let schedule = contract_data.vesting_schedule;
        (
            contract_data.withdrawal_address,
            contract_data.admin,
            schedule.period_duration,
            schedule.last_vested_period,
            contract_data.state,
        )
    }

    #[view]
    /// Returns the vesting record of a specific shareholder.
    ///
    /// # Arguments
    /// * `contract` - The address of the vesting contract.
    /// * `shareholder` - The address of the shareholder.
    ///
    /// # Returns
    /// A tuple containing:
    /// * `init_amount` - The initial vested amount assigned to the shareholder.
    /// * `left_amount` - The remaining (unclaimed) vested amount.
    /// * `last_vested_period` - The last vesting period index for this shareholder.
    public fun get_shareholder_vesting_record(
        contract: address,
        shareholder: address
    ): (u64, u64, u64) acquires VestingContract
    {
        assert!(exists<VestingContract>(contract), ERROR_CONTRACT_NOT_FOUND);

        let record = simple_map::borrow(
            &borrow_global<VestingContract>(contract).shareholders,
            &shareholder,
        );
        (
            record.init_amount,
            record.left_amount,
            record.last_vested_period
        )
    }

    #[view]
    /// Returns the remaining unclaimed vesting amount for a given shareholder.
    ///
    /// # Arguments
    /// * `contract` - The address of the vesting contract.
    /// * `shareholder` - The address of the shareholder.
    ///
    /// # Returns
    /// * `left_amount` - The remaining grant (unclaimed vested tokens) of the shareholder.
    public fun get_remaining_grant(
        contract: address,
        shareholder: address
    ): u64 acquires VestingContract
    {
        assert!(exists<VestingContract>(contract), ERROR_CONTRACT_NOT_FOUND);

        simple_map::borrow(
            &borrow_global<VestingContract>(contract).shareholders,
            &shareholder,
        ).left_amount
    }

    #[view]
    /// Returns all shareholder addresses for a given vesting contract.
    ///
    /// # Arguments
    /// * `contract` - Address of the vesting contract.
    ///
    /// # Returns
    /// * `vector<address>` - List of shareholder addresses.
    public fun view_shareholders(
        contract: address,
    ): vector<address> acquires VestingContract {
        assert!(exists<VestingContract>(contract), ERROR_CONTRACT_NOT_FOUND);
        let shareholders = &borrow_global<VestingContract>(contract).shareholders;
        simple_map::keys(shareholders)
    }

    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 FRIEND FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                 INTERNAL FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------

    inline fun validate_args(
        period_duration: u64,
        denominator: u64,
        numerators: vector<u64>,
        shareholders: vector<address>,
        shares: vector<u64>,
        start_timestamp_secs: u64
    )
    {
        assert!(start_timestamp_secs >= timestamp::now_seconds(), ERROR_INVALID_START_TIME);
        assert!(period_duration > 0, ERROR_INVALID_PERIOD_DURATION);
        assert!(denominator > 0, ERROR_INVALID_DENOMINATOR);
        let sum = vector::fold(
            numerators,
            0,
            |acc, numerator| { acc + numerator },
        );
        assert!(
            sum > 0,
            ERROR_INVALID_NUMERATORS
        );
        assert!(
            sum <= denominator,
            ERROR_INVALID_NUMERATORS
        );

        let shareholders_len = vector::length(&shareholders);

        assert!(
            shareholders_len > 0,
            ERROR_INVALID_SHAREHOLDER
        );

        assert!(
            shareholders_len == vector::length(&shares),
            ERROR_INVALID_SHAREHOLDER
        );

        // Numerators must not be empty, and the first and last elements must not be zero
        assert!(
            !vector::is_empty(&numerators) && *vector::borrow(&numerators, 0) != 0 && *vector::borrow(
                &numerators,
                vector::length(&numerators) - 1
            ) > 0,
            ERROR_INVALID_NUMERATORS
        );
    }

    inline fun set_terminate_vesting_contract(contract_address: address, contract: &mut VestingContract)
    {
        contract.state = CONTRACT_STATE_TERMINATED;
        event::emit(
            TerminateEvent {
                admin: contract.admin,
                vesting_contract_address: contract_address
            },
        );
    }

    inline fun assert_admin(admin: address)
    {
        let vesting_store = borrow_global<VestingStore>(get_vesting_store_address());
        assert!(vesting_store.admin == admin, ERROR_NOT_ADMIN);
    }

    fun vesting_internal(
        contract_address: address,
        contract_state: &mut VestingContract,
        shareholder_address: address
    )
    {
        assert!(
            simple_map::contains_key(&contract_state.shareholders, &shareholder_address),
            ERROR_SHAREHOLDER_NOT_EXISTS
        );

        let vesting_schedule = &contract_state.vesting_schedule;
        let period_duration = vesting_schedule.period_duration;
        let vesting_starts_at = contract_state.vesting_schedule.start_timestamp_secs;

        let beneficiary = get_beneficiary(contract_state.beneficiaries, &shareholder_address);
        let vesting_record =
            simple_map::borrow_mut(&mut contract_state.shareholders, &shareholder_address);
        let schedules = &vesting_schedule.schedules;
        let last_period = vesting_record.last_vested_period;
        let next_period = last_period + 1;
        let left_amount = vesting_record.left_amount;

        let completed_periods =
            (timestamp::now_seconds() - vesting_starts_at) / period_duration;

        let total_fraction = fixed_point32::create_from_rational(0, 1);

        // Loop through eligible periods from next_period up to completed_periods
        while (completed_periods >= next_period
            && left_amount > 0
            && next_period <= vector::length(schedules)) {
            let schedule_idx = next_period - 1;
            let fraction = *vector::borrow(schedules, schedule_idx);

            total_fraction = fixed_point32::add(total_fraction, fraction);

            next_period = next_period + 1;
        };

        // Optional fast-forward calculation if for some reason next_period was skipped
        let period_fast_forward: u64 = 0;

        // Handle corner case where last vested period is greater or equal to next_period
        if (completed_periods >= next_period && left_amount > 0) {
            let final_fraction = *vector::borrow(schedules, vector::length(schedules)
                - 1);

            // Calculate how many periods were missed and should be fast-forwarded
            period_fast_forward = completed_periods - next_period + 1;

            let add_fraction =
                fixed_point32::multiply_u64_return_fixpoint32(
                    period_fast_forward, final_fraction
                );

            total_fraction = fixed_point32::add(total_fraction, add_fraction);
        };

        let is_transferred =
            vest_transfer(
                vesting_record,
                &contract_state.extendRef,
                beneficiary,
                total_fraction
            );

        //If no amount was transferred DO NOT advance last_vested_period in the vesting record
        // This check is needed because if the fraction is too low, `vesting_record.init_amount * vesting_fraction`
        // may be 0. By not advancing, we allow for the possibility for `vesting_fraction` to become large enough
        // otherwise, even if vesting period passes and shareholder regularly calls `vest_individual`, the shareholder
        // may never receive any amount.
        if (!is_transferred) { return };
        next_period = next_period + period_fast_forward;

        event::emit(
            VestEvent {
                admin: contract_state.admin,
                shareholder: shareholder_address,
                vesting_contract: contract_address,
                period_vested: next_period - 1
            }
        );

        // Updating the `last_vested_period`
        vesting_record.last_vested_period = next_period - 1;
    }

    /// Create the unique resource account to store `VestingContract`
    fun create_vesting_contract_account(
        admin: &signer,
        vesting_store: &mut VestingStore
    ): ExtendRef {
        let store_addr = get_vesting_store_address();
        let seed = VESTING_RESOURCE_SEED;
        let nonce = vesting_store.nonce;

        vector::append(&mut seed, to_bytes(&store_addr));
        vector::append(&mut seed, to_bytes(&nonce));
        vesting_store.nonce = nonce + 1;

        let constructorRef = &object::create_named_object(admin, seed);
        object::generate_extend_ref(constructorRef)
    }

    /// Retries the beneficiary of the shareholder
    fun get_beneficiary(
        beneficiaries: SimpleMap<address, address>, addr: &address
    ): address {
        if (simple_map::contains_key(&beneficiaries, addr)) {
            *simple_map::borrow(&beneficiaries, addr)
        } else { *addr }
    }

    /// Transfers from the contract to beneficiary `vesting_fraction` of `vesting_record.init_amount`
    /// It returns whether any amount was transferred or not.
    fun vest_transfer(
        vesting_record: &mut VestingRecord,
        extendRef: &ExtendRef,
        beneficiary: address,
        fraction: FixedPoint32
    ): bool {
        let contract_signer = object::generate_signer_for_extending(extendRef);
        let amount =
            min(
                vesting_record.left_amount,
                fixed_point32::multiply_u64(vesting_record.init_amount, fraction)
            );

        if (amount > 0) {
            vesting_record.left_amount = vesting_record.left_amount - amount;
            // Transfer to beneficiary
            primary_fungible_store::transfer(
                &contract_signer,
                dxlyn_coin::get_dxlyn_asset_metadata(),
                beneficiary,
                amount
            );
            true
        } else { false }
    }


    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                                TEST ONLY FUNCTIONS
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------


    #[test_only]
    public fun test_init(deployer: &signer) {
        init_module(deployer);
    }

    #[test_only]
    public fun schedule_vesting_contract(
        deployer: &signer,
        shareholders: vector<address>,
        shares: vector<u64>,
        numerators: vector<u64>,
        denominator: u64,
        start_timestamp_secs: u64,
        period_duration: u64,
        withdrawal_address: address
    ): address acquires VestingStore {
        create_vesting_contract_with_amounts(
            deployer,
            shareholders,
            shares,
            numerators,
            denominator,
            start_timestamp_secs,
            period_duration,
            withdrawal_address
        );

        let store_address = get_vesting_store_address();
        let vesting_store = borrow_global_mut<VestingStore>(store_address);
        let vesting_contracts = &vesting_store.vesting_contracts;
        let contract_addr = vector::borrow(
            vesting_contracts,
            vector::length(vesting_contracts) - 1
        );

        *contract_addr
    }

    #[test_only]
    public fun get_contract_schedule(addr: address): (u64, u64, u64) acquires VestingContract {
        let contract = borrow_global<VestingContract>(addr);
        let schedule = contract.vesting_schedule;
        (
            schedule.period_duration,
            schedule.start_timestamp_secs,
            schedule.last_vested_period
        )
    }
}
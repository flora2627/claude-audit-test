#[test_only]
module dexlyn_tokenomics::poc_kill_gauge_simple
{
    use std::signer::address_of;
    use std::debug;

    use dexlyn_coin::dxlyn_coin;
    use dexlyn_swap::curves::Uncorrelated;
    use dexlyn_swap::liquidity_pool;
    use dexlyn_swap::scripts;
    use supra_framework::account;
    use supra_framework::coin;
    use supra_framework::genesis;
    use supra_framework::timestamp;
    use test_coin_admin::test_coins::{Self, BTC, USDT};
    use test_helpers::test_multisig;
    use test_helpers::test_pool::{create_lp_owner, initialize_liquidity_pool};

    use dexlyn_tokenomics::fee_distributor;
    use dexlyn_tokenomics::minter;
    use dexlyn_tokenomics::test_internal_coins;
    use dexlyn_tokenomics::voter;
    use dexlyn_tokenomics::voting_escrow;
    use dexlyn_tokenomics::voting_escrow_test::get_nft_token_address;

    const WEEK: u64 = 604800;
    const DXLYN_DECIMAL: u64 = 100000000;
    const MAXTIME: u64 = 126144000;

    public fun get_quants(amt: u64): u64 {
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
        voting_escrow::initialize(dev);
        fee_distributor::initialize(dev);
        voter::initialize(dev);
    }

    #[test(dev = @dexlyn_tokenomics)]
    fun test_kill_gauge_debug(dev: &signer) {
        setup_test_with_genesis(dev);
        fee_distributor::toggle_allow_checkpoint_token(dev);

        // Setup liquidity pool
        test_multisig::supra_coin_initialize_for_test_without_aggregator_factory();
        initialize_liquidity_pool();
        let coin_admin = test_coins::create_admin_with_coins();
        let lp_owner = create_lp_owner();
        coin::register<USDT>(&lp_owner);
        coin::register<BTC>(&lp_owner);

        let coin_value = get_quants(10_000_000_000);
        scripts::register_pool<BTC, USDT, Uncorrelated>(&lp_owner);
        let usdt_coins = test_coins::mint<USDT>(&coin_admin, coin_value);
        let btc_coins = test_coins::mint<BTC>(&coin_admin, coin_value);
        coin::deposit(address_of(&lp_owner), usdt_coins);
        coin::deposit(address_of(&lp_owner), btc_coins);
        scripts::add_liquidity<BTC, USDT, Uncorrelated>(
            &lp_owner,
            get_quants(10_000_000_000),
            get_quants(10_000_000_000),
            get_quants(10_000_000_000),
            get_quants(10_000_000_000),
        );

        let pool_addr = liquidity_pool::generate_lp_object_address<BTC, USDT, Uncorrelated>();

        // Whitelist and create gauge
        voter::whitelist_cpmm_pool<BTC, USDT, Uncorrelated>(dev);
        voter::create_gauge(dev, pool_addr);
        let gauge_addr = voter::get_gauge_for_pool(pool_addr);

        // Create voting power
        dxlyn_coin::register_and_mint(dev, address_of(dev), 1000 * DXLYN_DECIMAL);
        let unlock_time = timestamp::now_seconds() + MAXTIME;
        voting_escrow::create_lock(dev, 1000 * DXLYN_DECIMAL, unlock_time);
        let (nft_token_address, _) = get_nft_token_address(1);

        // Vote
        voter::vote(dev, nft_token_address, vector[pool_addr], vector[100]);

        debug::print(&b"=== INITIAL STATE ===");
        let (_, _, _, _, _, _, balance0) = voter::get_voter_state();
        debug::print(&b"Voter balance:");
        debug::print(&balance0);
        debug::print(&b"Gauge claimable:");
        debug::print(&voter::get_claimable(gauge_addr));

        // Fast forward and trigger emission
        timestamp::fast_forward_seconds(WEEK);
        let dxlyn_minter = minter::get_minter_object_address();
        voter::set_minter(dev, dxlyn_minter);
        voter::update_period();

        debug::print(&b"=== AFTER UPDATE_PERIOD ===");
        let (_, _, _, _, _, _, balance1) = voter::get_voter_state();
        debug::print(&b"Voter balance:");
        debug::print(&balance1);
        debug::print(&b"Gauge claimable:");
        debug::print(&voter::get_claimable(gauge_addr));

        // Fast forward again
        timestamp::fast_forward_seconds(WEEK);

        debug::print(&b"=== AFTER ANOTHER WEEK ===");
        let (_, _, _, _, _, _, balance2) = voter::get_voter_state();
        debug::print(&b"Voter balance:");
        debug::print(&balance2);
        debug::print(&b"Gauge claimable:");
        debug::print(&voter::get_claimable(gauge_addr));

        // Kill gauge
        voter::kill_gauge(dev, gauge_addr);

        debug::print(&b"=== AFTER KILL ===");
        let (_, _, _, _, _, _, balance3) = voter::get_voter_state();
        debug::print(&b"Voter balance:");
        debug::print(&balance3);
        debug::print(&b"Gauge claimable:");
        debug::print(&voter::get_claimable(gauge_addr));

        // Try to distribute
        voter::distribute_all(dev);

        debug::print(&b"=== AFTER DISTRIBUTE ===");
        let (_, _, _, _, _, _, balance4) = voter::get_voter_state();
        debug::print(&b"Voter balance:");
        debug::print(&balance4);
        debug::print(&b"Gauge claimable:");
        debug::print(&voter::get_claimable(gauge_addr));

        // Verify: voter balance should be greater than zero but claimable is zero
        assert!(balance4 > 0, 100);
        assert!(voter::get_claimable(gauge_addr) == 0, 101);
    }
}

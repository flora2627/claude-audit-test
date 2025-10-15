#[test_only]
module dexlyn_tokenomics::test_internal_coins {

    use std::option;
    use std::signer::address_of;
    use std::string::{String, utf8};

    use dexlyn_coin::dxlyn_coin;
    use supra_framework::account::create_signer_for_test;
    use supra_framework::coin;
    use supra_framework::coin::{BurnCapability, is_account_registered, MintCapability, register};
    use supra_framework::fungible_asset::{Self, Metadata, MintRef, TransferRef};
    use supra_framework::object;
    use supra_framework::primary_fungible_store;

    const SC_ADMIN: address = @dexlyn_tokenomics;

    #[test_only]
    struct ManagedFungibleAsset has key {
        mint_ref: MintRef,
        transfer_ref: TransferRef
    }

    struct Capabilities<phantom CoinType> has key {
        mint_cap: MintCapability<CoinType>,
        burn_cap: BurnCapability<CoinType>,
    }


    public fun init_coin(signer: &signer) {
        dxlyn_coin::init_coin(signer);
    }

    public fun supra_coin_initialize_for_test_without_aggregator_factory() {
        let framework_signer = &create_signer_for_test(@supra_framework);
        let (burn, mint) = supra_framework::supra_coin::initialize_for_test_without_aggregator_factory(
            framework_signer
        );
        coin::destroy_mint_cap(mint);
        coin::destroy_burn_cap(burn);
    }

    public fun init_legacy_coin<CoinType>(
        account: &signer,
        name: String,
        symbol: String,
        decimal: u8,
        monitor_suppy: bool
    ) {
        let (dxlp_burn_cap, dxlp_freeze_cap, dxlp_mint_cap) =
            coin::initialize<CoinType>(
                account,
                name,
                symbol,
                decimal,
                monitor_suppy,
            );

        move_to(account, Capabilities<CoinType> {
            mint_cap: dxlp_mint_cap,
            burn_cap: dxlp_burn_cap,
        });

        coin::destroy_freeze_cap(dxlp_freeze_cap);
    }

    public fun init_usdt_coin(account: &signer) {
        let constructor_ref = &object::create_named_object(account, b"USDT");

        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref,
            option::none(),
            utf8(b"USDT Coin"), /* name */
            utf8(b"USDT"), /* symbol */
            8, /* decimals */
            utf8(b"http://example.com/favicon.ico"), /* icon */
            utf8(b"http://example.com") /* project */
        );

        let mint_ref = fungible_asset::generate_mint_ref(constructor_ref);
        let transfer_ref = fungible_asset::generate_transfer_ref(constructor_ref);

        let signer = object::generate_signer(constructor_ref);
        move_to(&signer, ManagedFungibleAsset { mint_ref, transfer_ref });
    }

    public fun init_bct_coin(account: &signer) {
        let constructor_ref = &object::create_named_object(account, b"BTC");

        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref,
            option::none(),
            utf8(b"BTC Coin"), /* name */
            utf8(b"BTC"), /* symbol */
            8, /* decimals */
            utf8(b"http://example.com/favicon.ico"), /* icon */
            utf8(b"http://example.com") /* project */
        );

        let mint_ref = fungible_asset::generate_mint_ref(constructor_ref);
        let transfer_ref = fungible_asset::generate_transfer_ref(constructor_ref);

        let signer = object::generate_signer(constructor_ref);
        move_to(&signer, ManagedFungibleAsset { mint_ref, transfer_ref });
    }

    public fun init_usdc_coin(account: &signer) {
        let constructor_ref = &object::create_named_object(account, b"USDC");

        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref,
            option::none(),
            utf8(b"USDC Coin"), /* name */
            utf8(b"USDC"), /* symbol */
            8, /* decimals */
            utf8(b"http://example.com/favicon.ico"), /* icon */
            utf8(b"http://example.com") /* project */
        );

        let mint_ref = fungible_asset::generate_mint_ref(constructor_ref);
        let transfer_ref = fungible_asset::generate_transfer_ref(constructor_ref);

        let signer = object::generate_signer(constructor_ref);
        move_to(&signer, ManagedFungibleAsset { mint_ref, transfer_ref });
    }

    public fun register_and_mint_usdt(
        account: &signer, to: address, amount: u64
    ) acquires ManagedFungibleAsset {
        let object_add = object::create_object_address(&address_of(account), b"USDT");

        let cap = borrow_global<ManagedFungibleAsset>(object_add);

        let coin = fungible_asset::mint(&cap.mint_ref, amount);

        let asset = object::address_to_object<Metadata>(object_add);

        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, asset);

        fungible_asset::deposit(to_wallet, coin);
    }

    public fun register_and_mint_usdc(
        account: &signer, to: address, amount: u64
    ) acquires ManagedFungibleAsset {
        let object_add = object::create_object_address(&address_of(account), b"USDC");

        let cap = borrow_global<ManagedFungibleAsset>(object_add);

        let coin = fungible_asset::mint(&cap.mint_ref, amount);

        let asset = object::address_to_object<Metadata>(object_add);

        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, asset);

        fungible_asset::deposit(to_wallet, coin);
    }

    public fun register_and_mint_btc(
        account: &signer, to: address, amount: u64
    ) acquires ManagedFungibleAsset {
        let object_add = object::create_object_address(&address_of(account), b"BTC");

        let cap = borrow_global<ManagedFungibleAsset>(object_add);

        let coin = fungible_asset::mint(&cap.mint_ref, amount);

        let asset = object::address_to_object<Metadata>(object_add);

        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, asset);

        fungible_asset::deposit(to_wallet, coin);
    }

    public fun register_and_mint_legacy_coin<CoinType>(
        account: &signer, to: address, amount: u64
    ) acquires Capabilities {
        let account_address = address_of(account);
        let cap = borrow_global<Capabilities<CoinType>>(account_address);

        let coin = coin::mint(amount, &cap.mint_cap);

        if (!is_account_registered<CoinType>(to)) {
            register<CoinType>(&create_signer_for_test(to));
        };
        coin::deposit(to, coin);
    }

    public fun get_usdc_metadata(account: &signer): address {
        object::create_object_address(&address_of(account), b"USDC")
    }

    public fun get_usdt_metadata(account: &signer): address {
        object::create_object_address(&address_of(account), b"USDT")
    }

    public fun get_btc_metadata(account: &signer): address {
        object::create_object_address(&address_of(account), b"BTC")
    }

    public fun get_user_usdt_balance(user_addr: address): u64 {
        //usdt coin metadata
        let usdt_coin_address = object::create_object_address(&SC_ADMIN, b"USDT");
        let usdt_coin_metadata = object::address_to_object<Metadata>(usdt_coin_address);

        primary_fungible_store::balance(user_addr, usdt_coin_metadata)
    }
}
#[test_only]
module dexlyn_tokenomics::test_nft {

    use std::option;
    use std::signer;
    use std::string::{Self, String};

    use aptos_token_objects::collection;
    use aptos_token_objects::token::{create_named_token, create_token_address, Token};
    use supra_framework::object::{Self, ConstructorRef, ExtendRef};

    #[test_only]
    fun create_collection_helper(creator: &signer, collection_name: String, max_supply: u64): ExtendRef {
        let constructor_ref = create_fixed_collection(creator, collection_name, max_supply);
        object::generate_extend_ref(&constructor_ref)
    }

    #[test_only]
    fun create_fixed_collection(creator: &signer, collection_name: String, max_supply: u64): ConstructorRef {
        collection::create_fixed_collection(
            creator,
            string::utf8(b"collection description"),
            max_supply,
            collection_name,
            option::none(),
            string::utf8(b"collection uri"),
        )
    }

    #[test_only]
    fun create_token_helper(creator: &signer, collection_name: String, token_name: String): ConstructorRef {
        create_named_token(
            creator,
            collection_name,
            string::utf8(b"token description"),
            token_name,
            option::none(),
            string::utf8(b"uri"),
        )
    }

    #[test_only]
    public fun test_create_and_transfer(
        creator: &signer,
        trader: &signer,
        collection_name: vector<u8>,
        token_name: vector<u8>
    ): address {
        let collection_name = string::utf8(collection_name);
        let token_name = string::utf8(token_name);

        create_collection_helper(creator, collection_name, 1);
        create_token_helper(creator, collection_name, token_name);

        let creator_address = signer::address_of(creator);
        let token_addr = create_token_address(&creator_address, &collection_name, &token_name);
        let token = object::address_to_object<Token>(token_addr);
        object::transfer(creator, token, signer::address_of(trader));
        token_addr
    }
}
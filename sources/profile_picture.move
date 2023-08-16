module aptos_identify::profile_picture {
    use std::option;
    use std::option::Option;
    use std::signer::address_of;
    use std::string;
    use std::string::{String, utf8};
    use aptos_framework::object;
    use aptos_framework::object::ObjectCore;
    use aptos_token::token::{Self, TokenDataId as TokenDataIdV1, TokenId as TokenIdV1, Token as TokenV1};
    use aptos_token_objects::token::Token as TokenV2;

    const MODE_UNSET: u8 = 0;
    const MODE_USE_TOKEN_V1: u8 = 1;
    const MODE_USE_TOKEN_V2: u8 = 2;

    struct TokenV1Extension has store {
        pfp_token_data_id: TokenDataIdV1,
    }

    struct TokenV2Extension has store {
        pfp_address: address
    }

    struct Pfp has key {
        mode: u8,
        token_v1_ext: Option<TokenV1Extension>,
        token_v2_ext: Option<TokenV2Extension>,
    }

    // == EXECUTE ==

    public entry fun set_token_v1_pfp(user: signer, token_id: TokenIdV1) acquires Pfp {
        let user_addr = address_of(&user);
        if (!exists<Pfp>(user_addr)) {
            // Create a new record
            move_to(&user, Pfp { mode: MODE_USE_TOKEN_V1, token_v1_ext: {} });
        } else {
            // Update the existing record
            let pfp_record = borrow_global_mut<Pfp>(user_addr);
            pfp_record.pfp_address = pfp_address;
        }
    }

    public entry fun set_token_v2_pfp(user: signer, pfp_address: address) acquires Pfp {
        let user_addr = address_of(&user);
        if (!exists<Pfp>(user_addr)) {
            // Create a new record
            move_to(&user, Pfp { pfp_address });
        } else {
            // Update the existing record
            let pfp_record = borrow_global_mut<Pfp>(user_addr);
            pfp_record.pfp_address = pfp_address;
        }
    }

    // == QUERY ==

    #[view]
    public fun get_token_v1_pfp(of: address): Option<address> acquires Pfp{
        if (!exists<Pfp>(of)) {
            option::none()
        } else {
            let pfp_record = borrow_global<Pfp>(of);

            let record_obj = object::address_to_object<NameRecord>(token_addr_inline(domain_name, subdomain_name));
            object::owns(record_obj, of)

            pfp_record.pfp_address
        }
    }

    #[view]
    public fun get_token_v2_pfp(of: address): Option<TokenId> acquires Pfp{
        if (!exists<Pfp>(of)) {
            option::none()
        } else {
            let pfp_record = borrow_global<Pfp>(of);

            let record_obj = object::address_to_object<NameRecord>(token_addr_inline(domain_name, subdomain_name));
            object::owns(record_obj, of)

            pfp_record.pfp_address
        }
    }

    #[view]
    public fun get_pfp_url(of: address): Option<String> acquires Pfp{

    }

    // == HELPER ==

    public  fun is_owner_of_token_v1(owner_address: address, token_id: TokenId): bool {
        token::balance_of(owner_address, token_id) > 0
    }

    public  fun is_owner_of_token_v2(owner_address: address, token_address: address): bool {
        let record_obj = object::address_to_object<TokenV2>(token_address);
        object::owns(record_obj, owner_address)
    }
}

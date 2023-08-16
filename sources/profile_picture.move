module aptos_identify::profile_picture {
    use std::option;
    use std::option::Option;
    use std::signer;
    use std::signer::address_of;
    use std::string;
    use std::string::{String, utf8};
    use aptos_framework::object;
    use aptos_token::token::{Self, TokenDataId as TokenDataIdV1, TokenId as TokenIdV1, Token as TokenV1};
    use aptos_token_objects::token::Token as TokenV2;

    struct Pfp has key {
        pfp_address: address
    }

    // == EXECUTE ==

    public entry fun set_pfp(sender: signer, pfp_address: address) acquires Pfp {
        let user_addr = address_of(&sender);
        if (!is_owner_of_nft(user_addr, pfp_address)) {
            return
        };
        if (!exists<Pfp>(user_addr)) {
            // Create a new record
            move_to(&sender, Pfp { pfp_address });
        } else {
            // Update the existing record
            let pfp_record = borrow_global_mut<Pfp>(user_addr);
            pfp_record.pfp_address = pfp_address;
        }
    }

    // == QUERY ==

    #[view]
    public fun get_pfp(sender: address): Option<address> acquires Pfp {
        if (!exists<Pfp>(sender)) {
            option::none()
        } else {
            let pfp_record = borrow_global<Pfp>(sender);
            if (is_owner_of_nft(sender, pfp_record.pfp_address)) {
                option::some(pfp_record.pfp_address)
            } else {
                option::none()
            }
        }
    }

    // == HELPER ==

    public fun is_owner_of_nft(owner_address: address, token_address: address): bool {
        let record_obj = object::address_to_object<TokenV2>(token_address);
        object::owns(record_obj, owner_address)
    }
}

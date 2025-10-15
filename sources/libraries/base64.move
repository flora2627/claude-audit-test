module dexlyn_tokenomics::base64 {

    use std::string;
    use std::vector;

    /// Encode binary data to Base64 string
    public fun encode(data: &vector<u8>): string::String {
        let result = vector::empty<u8>();
        let i = 0;
        let data_len = vector::length(data);

        // Base64 encoding table
        let base64_table: vector<u8> = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

        while (i < data_len) {
            let b0 = *vector::borrow(data, i);
            let b1 = if (i + 1 < data_len) { *vector::borrow(data, i + 1) } else { 0 };
            let b2 = if (i + 2 < data_len) { *vector::borrow(data, i + 2) } else { 0 };

            let triple = ((b0 as u32) << 16) | ((b1 as u32) << 8) | (b2 as u32);

            vector::push_back(&mut result, *vector::borrow(&base64_table, (((triple >> 18) & 0x3F) as u64)));
            vector::push_back(&mut result, *vector::borrow(&base64_table, (((triple >> 12) & 0x3F) as u64)));

            if (i + 1 < data_len) {
                vector::push_back(&mut result, *vector::borrow(&base64_table, (((triple >> 6) & 0x3F) as u64)));
            } else {
                vector::push_back(&mut result, 61); // '='
            };

            if (i + 2 < data_len) {
                vector::push_back(&mut result, *vector::borrow(&base64_table, ((triple & 0x3F) as u64)));
            } else {
                vector::push_back(&mut result, 61); // '='
            };

            i = i + 3;
        };

        string::utf8(result)
    }
}
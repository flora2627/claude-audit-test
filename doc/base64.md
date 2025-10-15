
<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_base64"></a>

# Module `0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f::base64`



-  [Function `encode`](#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_base64_encode)


<pre><code><b>use</b> <a href="">0x1::string</a>;
</code></pre>



<a id="0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_base64_encode"></a>

## Function `encode`

Encode binary data to Base64 string


<pre><code><b>public</b> <b>fun</b> <a href="base64.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_base64_encode">encode</a>(data: &<a href="">vector</a>&lt;u8&gt;): <a href="_String">string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="base64.md#0xecc6c5425f6328f7e7b9ef17d5b287932c2bb1806058ee99bebef38fb367112f_base64_encode">encode</a>(data: &<a href="">vector</a>&lt;u8&gt;): <a href="_String">string::String</a> {
    <b>let</b> result = <a href="_empty">vector::empty</a>&lt;u8&gt;();
    <b>let</b> i = 0;
    <b>let</b> data_len = <a href="_length">vector::length</a>(data);

    // Base64 encoding <a href="">table</a>
    <b>let</b> base64_table: <a href="">vector</a>&lt;u8&gt; = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    <b>while</b> (i &lt; data_len) {
        <b>let</b> b0 = *<a href="_borrow">vector::borrow</a>(data, i);
        <b>let</b> b1 = <b>if</b> (i + 1 &lt; data_len) { *<a href="_borrow">vector::borrow</a>(data, i + 1) } <b>else</b> { 0 };
        <b>let</b> b2 = <b>if</b> (i + 2 &lt; data_len) { *<a href="_borrow">vector::borrow</a>(data, i + 2) } <b>else</b> { 0 };

        <b>let</b> triple = ((b0 <b>as</b> u32) &lt;&lt; 16) | ((b1 <b>as</b> u32) &lt;&lt; 8) | (b2 <b>as</b> u32);

        <a href="_push_back">vector::push_back</a>(&<b>mut</b> result, *<a href="_borrow">vector::borrow</a>(&base64_table, (((triple &gt;&gt; 18) & 0x3F) <b>as</b> u64)));
        <a href="_push_back">vector::push_back</a>(&<b>mut</b> result, *<a href="_borrow">vector::borrow</a>(&base64_table, (((triple &gt;&gt; 12) & 0x3F) <b>as</b> u64)));

        <b>if</b> (i + 1 &lt; data_len) {
            <a href="_push_back">vector::push_back</a>(&<b>mut</b> result, *<a href="_borrow">vector::borrow</a>(&base64_table, (((triple &gt;&gt; 6) & 0x3F) <b>as</b> u64)));
        } <b>else</b> {
            <a href="_push_back">vector::push_back</a>(&<b>mut</b> result, 61); // '='
        };

        <b>if</b> (i + 2 &lt; data_len) {
            <a href="_push_back">vector::push_back</a>(&<b>mut</b> result, *<a href="_borrow">vector::borrow</a>(&base64_table, ((triple & 0x3F) <b>as</b> u64)));
        } <b>else</b> {
            <a href="_push_back">vector::push_back</a>(&<b>mut</b> result, 61); // '='
        };

        i = i + 3;
    };

    <a href="_utf8">string::utf8</a>(result)
}
</code></pre>



</details>

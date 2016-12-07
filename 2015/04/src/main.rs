extern crate crypto;

use crypto::md5::Md5;
use crypto::digest::Digest;

fn main() {
    let answer = number_producing_hash_starting_with("00000");
    let bonus  = number_producing_hash_starting_with("000000");
    println!("Puzzle answer: {}", answer);
    println!("Bonus answer: {}", bonus);
}

static INPUT: &'static str = "bgvyzdsv";

fn number_producing_hash_starting_with(prefix: &str) -> u32 {
    let mut n = 0;
    loop {
        if is_good_number(n, prefix) {
            return n;
        }
        n += 1;
    }
}

fn is_good_number(n: u32, prefix: &str) -> bool {
    let s = format!("{}{}", INPUT, n);
    let m = md5_as_hex(&s);
    m.starts_with(prefix)
}

// input is a str (not &[u8]), output is a hex String
fn md5_as_hex(input: &str) -> String {
    let mut md5 = Md5::new();
    md5.input_str(input);
    md5.result_str()
}

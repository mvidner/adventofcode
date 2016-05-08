#![feature(pattern)]

use std::io;
use std::io::prelude::*;

extern crate core;
use core::str::pattern::Pattern;

fn main() {
    let stdin = io::stdin(); // interesting; cannot inline it in the next line
    let lines = stdin.lock().lines(); // an iterator
    let mut nice_count = 0;
    let mut nice_bonus_count = 0;
    for line in lines {
        let line = line.unwrap(); // panic if reading fails
        if is_nice(&line) {
            nice_count += 1;
        }
        if is_nice_for_bonus(&line) {
            nice_bonus_count += 1;
        }
    }
    println!("Number of nice strings: {}", nice_count);
    println!("Number of nice strings under revised rules: {}", nice_bonus_count);
}

fn is_nice(s: &str) -> bool {
    has_3_vowels(s) && has_double_letter(s) && !has_banned_pair(s)
}

fn has_3_vowels(s: &str) -> bool {
    let mut count: usize = 0;
    for c in s.chars() {
        match c {
            'a'|'e'|'i'|'o'|'u' => count +=1,
            _ => {}
        }
    }
    count >= 3
}

fn has_double_letter(s: &str) -> bool {
    let mut previous_letter = '0'; // initialized with a non-letter
    for c in s.chars() {
        if c == previous_letter {
            return true;
        }
        previous_letter = c;
    }
    false
}

fn has_banned_pair(s: &str) -> bool {
    "ab".is_contained_in(s) ||
        "cd".is_contained_in(s) ||
        "pq".is_contained_in(s) ||
        "xy".is_contained_in(s)
}

fn is_nice_for_bonus(s: &str) -> bool {
    has_repeated_pair(s) && has_sandwich(s)
}

fn has_repeated_pair(s: &str) -> bool {
    has_repeated_substring(2, s)
}

fn has_repeated_substring(substr_len: usize, s: &str) -> bool {
    if s.len() < 2 * substr_len { // must not overlap
        return false;
    }

    for start in 0 .. s.len() - (2 * substr_len) + 1 {
        let needle = &s[start .. start+substr_len];
        if needle.is_contained_in(&s[start+substr_len ..]) {
            return true;
        }
    }
    false
}

fn has_sandwich(s: &str) -> bool {
    let s = s.as_bytes();       // HACK, otherwise cannot index by characters
    if s.len() < 3 {
        return false;
    }

    for i in 0 .. s.len() - 3 + 1 {
        if s[i] == s[i + 2] {
            return true;
        }
    }
    false
}

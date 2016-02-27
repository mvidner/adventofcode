// http://adventofcode.com/day/2

// [u32; 3].iter().sum()
#![feature(iter_arith)]

use std::io;
use std::io::prelude::*;

#[derive(Debug)]
struct Present {
    w: u32,
    h: u32,
    l: u32,
}

fn main () {
    let mut presents: Vec<Present> = Vec::new();
    let stdin = io::stdin();
    for line in stdin.lock().lines() {
        let line = line.unwrap();

        let present = parse_line(&line);
        presents.push(present);
    }

    let total_paper: u32 = presents.iter().map(|p| paper_needed(&p)).sum();
    println!("Paper needed: {}", total_paper);

    let total_ribbon: u32 = presents.iter().map(|p| ribbon_needed(&p)).sum();
    println!("Ribbon needed: {}", total_ribbon);
}

fn paper_needed(p: &Present) -> u32 {
    let face_areas = [p.w * p.h, p.h * p.l, p.w * p.l];
    let slack: &u32 = face_areas.iter().min().unwrap();
    let half_area: u32 = face_areas.iter().sum();
    2 * half_area + slack
}

fn ribbon_needed(p: &Present) -> u32 {
    let bow = p.w * p.h * p.l;
    let face_circumferences = [2 * (p.w + p.h),
                               2 * (p.h + p.l),
                               2 * (p.w + p.l)];
    let min_face_c = face_circumferences.iter().min().unwrap();
    min_face_c + bow
}

fn parse_line(s: &String) -> Present {
    let split = s.split('x');

    let vec: Vec<&str> = split.collect();
    let (sw, sh, sl) = (vec[0], vec[1], vec[2]);
    let p = if let (Ok(w), Ok(h), Ok(l)) = (sw.parse::<u32>(),
                                            sh.parse::<u32>(),
                                            sl.parse::<u32>()) {
        Present {w: w, h: h, l: l}
    }
    else {
        Present {w: 0, h: 0, l: 0}
    };
    p
}

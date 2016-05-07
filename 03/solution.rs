// http://adventofcode.com/day/3

use std::io;
use std::io::prelude::*;
use std::collections::HashSet;

type Position = (i32, i32);
type PositionSet = HashSet<Position>;

fn read_instructions() -> String {
    let mut result = String::new();

    let stdin = io::stdin();
    stdin.lock().read_to_string(&mut result).unwrap();
    result
}

fn new_position(p: Position, i: char) -> Position {
    match i {
        '^' => (p.0,     p.1 + 1),
        '>' => (p.0 + 1, p.1),
        'v' => (p.0,     p.1 - 1),
        '<' => (p.0 - 1, p.1),
        _   => p
    }
}

fn main () {
    let instructions = read_instructions();

    one_santa(&instructions);
    two_santas(&instructions);
}

fn one_santa(instructions: &str) {
    let mut visited = PositionSet::new();
    let mut position = (0, 0);
    visited.insert(position);

    for instruction in instructions.chars() {
        position = new_position(position, instruction);
        visited.insert(position);
    }
    println!("Positions visited by a single Santa: {}", visited.len());
}

fn two_santas(instructions: &str) {
    let mut visited = PositionSet::new();
    let mut position = (0, 0);
    let mut robosanta_position = (0, 0);
    visited.insert(position);

    let mut santas_turn = true;

    for instruction in instructions.chars() {
        if santas_turn {
            position = new_position(position, instruction);
            visited.insert(position);
        }
        else {
            robosanta_position = new_position(robosanta_position, instruction);
            visited.insert(robosanta_position);
        }
        santas_turn = !santas_turn
    }
    println!("Positions visited by Santa & RoboSanta: {}", visited.len());
}

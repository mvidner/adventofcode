// http://adventofcode.com/day/1

use std::io;

fn final_floor(instructions: &String) -> i32 {
  let mut floor = 0;
  for insn in instructions.chars() {
      match insn {
	'(' => floor += 1,
	')' => floor -= 1,
	_   => { /* ignore */ }
      }
  }
  return floor;
}

fn first_entering_basement(instructions: &String) -> i32 {
  let mut floor = 0;
  let mut pc = 1;
  for insn in instructions.chars() {
      match insn {
	'(' => floor += 1,
	')' => floor -= 1,
	_   => { /* ignore */ }
      }

      if floor < 0 {
	return pc;
      }

      pc += 1;
  }
  return pc;
}

fn main() {
  println!("Reading from stdin. Usage: ./solution < input");

  let mut input = String::new();
  io::stdin().read_line(&mut input)
    .expect("Failed to read line");

  let answer = final_floor(&input);
  let bonus = first_entering_basement(&input);

  println!("Santa ends up on floor {}, \
	   and first enters the basement in step {}.", answer, bonus);
}

#!/usr/bin/env python3
import re
from collections import Counter

class PasswordPhilosophy(object):
    def __init__(self, input):
        self.lines = input.splitlines()

    @staticmethod
    def parse(line):
        match = re.search(r'(\d+)-(\d+) (.): (.*)', line)
        m = match.group(1, 2, 3, 4)
        return (int(m[0]), int(m[1]), m[2], m[3])

    @staticmethod
    def is_valid_old(line):
        (min, max, char, passw) = PasswordPhilosophy.parse(line)
        char_count = Counter(passw).get(char, 0)
        return min <= char_count <= max

    def count_valid_passwords_old(self):
        return sum(map(self.is_valid_old, self.lines))

    @staticmethod
    def is_valid_new(line):
        (first, second, char, passw) = PasswordPhilosophy.parse(line)
        first_match = passw[first - 1] == char
        second_match = passw[second - 1] == char

        return first_match != second_match

    def count_valid_passwords_new(self):
        return sum(map(self.is_valid_new, self.lines))


if __name__ == '__main__':
    with open("input.txt") as f:
        input = f.read()
    sol = PasswordPhilosophy(input)

    print("Part 1")
    print(sol.count_valid_passwords_old())

    print("Part 2")
    print(sol.count_valid_passwords_new())

#!/usr/bin/env python3
import sys
import re

class Lights(object):
    def __init__(self):
        size = 1000
        make_row = lambda: [0 for _ in range(size)]
        self.lights = [make_row() for _ in range(size)]

    def process(self, input):
        insns = input.strip().split("\n")
        for insn in insns:
            # print(repr(insn))
            m = re.fullmatch(r"(\D+) (\d+),(\d+) through (\d+),(\d+)", insn)
            if m:
                verb = m.group(1)
                if verb == "turn on":
                    action = self.turn_on
                elif verb == "turn off":
                    action = self.turn_off
                elif verb == "toggle":
                    action = self.toggle
                else:
                    raise RuntimeError("bad verb")

                (ar, ac, br, bc) = [int(i) for i in m.groups()[1:]]
                for r in range(ar, br+1):
                    for c in range(ac, bc+1):
                        action(r, c)
            else:
                raise RuntimeError("bad insn")

    def turn_on(self, r, c):
        self.lights[r][c] = 1

    def turn_off(self, r, c):
        self.lights[r][c] = 0

    def toggle(self, r, c):
        self.lights[r][c] = 1 - self.lights[r][c]

    def lit(self):
        return sum([sum(row) for row in self.lights])

class Lights2(Lights):
    def turn_on(self, r, c):
        self.lights[r][c] += 1

    def turn_off(self, r, c):
        self.lights[r][c] = max(0, self.lights[r][c] - 1)

    def toggle(self, r, c):
        self.lights[r][c] += 2

if __name__ == '__main__':
    fn = sys.argv[1] if len(sys.argv) > 1 else "input.txt"
    with open(fn) as f:
        input = f.read()
    sol = Lights()
    sol.process(input)

    print("Part 1, number of lights lit")
    print(sol.lit())

    sol2 = Lights2()
    sol2.process(input)

    print("Part 2, brightness with modified meaning")
    print(sol2.lit())

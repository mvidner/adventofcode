#!/usr/bin/env python3
import sys
import re

class Lights(object):
    def __init__(self):
        size = 1000
        self.lights = [
            [False for _ in range(size)]
            for _ in range(size)
        ]

    def process(self, input):
        insns = input.strip().split("\n")
        for insn in insns:
            # print(repr(insn))
            m = re.fullmatch(r"(\D+) (\d+),(\d+) through (\d+),(\d+)", insn)
            if m:
                verb = m.group(1)
                (ar, ac, br, bc) = [int(i) for i in m.groups()[1:]]
                for r in range(ar, br+1):
                    for c in range(ac, bc+1):
                        if verb == "turn on":
                            self.lights[r][c] = True
                        elif verb == "turn off":
                            self.lights[r][c] = False
                        elif verb == "toggle":
                            self.lights[r][c] = not self.lights[r][c]
                        else:
                            raise RuntimeError("bad verb")
            else:
                raise RuntimeError("bad insn")

    def lit(self):
        return sum([
            sum([1 if e else 0 for e in row])
            for row in self.lights
        ])

if __name__ == '__main__':
    fn = sys.argv[1] if len(sys.argv) > 1 else "input.txt"
    with open(fn) as f:
        input = f.read()
    sol = Lights()
    sol.process(input)

    print("Part 1, number of lights lit")
    print(sol.lit())

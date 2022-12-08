#!/usr/bin/env python3
import sys

class Calories(object):
    def __init__(self, input):
        elves = input.split("\n\n")
        self.elves = [sum(map(int, e.split())) for e in elves]
        # print(self.elves)

    def max(self):
        return max(self.elves)

    def top3sum(self):
        sorted = self.elves[:]
        sorted.sort()           # bug: expecting a return value (Ruby)
        top3 = sorted[-3:]      # bug: [-3:-1]  (Ruby)
        return sum(top3)

if __name__ == '__main__':
    fn = sys.argv[1] if len(sys.argv) > 1 else "input.txt"
    with open(fn) as f:
        input = f.read()
    sol = Calories(input)

    print("Part 1, max calories")
    print(sol.max())

    print("Part 2, sum of top 3 calories")
    print(sol.top3sum())

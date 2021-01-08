#!/usr/bin/env python3
class ReportRepair(object):
    def __init__(self, input):
        self.entries = [int(line) for line in input.split()]

    def find_pair(self, sum):
        seen = set()

        for e in self.entries:
            other = sum - e
            if other in seen:
                return (other, e)
            seen.add(e)

        raise "No matching pair found"

    def find_triplet(self, sum):
        for a in self.entries:
            for b in self.entries:
                for c in self.entries:
                    if a + b + c == sum:
                        return (a, b, c)

        raise "No matching triplet found"


if __name__ == '__main__':
    with open("input.txt") as f:
        input = f.read()
    rr = ReportRepair(input)
    # print(repr(rr.entries))

    print("Part 1")
    a, b = rr.find_pair(2020)
    print(a * b)

    print("Part 2")
    a, b, c = rr.find_triplet(2020)
    print(a * b * c)

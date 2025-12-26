#!/usr/bin/env -S uv run
# /// script
# dependencies = [
#     "numpy",
#     "scipy",
# ]
# ///
# See https://packaging.python.org/en/latest/specifications/inline-script-metadata/
# aka PEP 723
import sys
import re

import numpy as np
from scipy.optimize import milp, LinearConstraint, Bounds

def solve_binary_system(A, b):
    """
    Solve Ax = b where A is binary, b is natural numbers, x is integer.
    Minimize sum(x).
    """
    m, n = A.shape  # m equations, n unknowns

    # Objective: minimize sum of x (coefficients are all 1)
    c = np.ones(n)

    # Constraint: Ax = b (equality constraint)
    constraints = LinearConstraint(A, lb=b, ub=b)

    # Bounds: x can be any integer (adjust if you know bounds)
    # For non-negative integers: bounds = Bounds(0, np.inf)
    # For unrestricted: bounds = Bounds(-np.inf, np.inf)
    bounds = Bounds(0, np.inf)  # assuming x >= 0

    # Specify that all variables are integers
    integrality = np.ones(n)  # 1 = integer, 0 = continuous

    # Solve
    result = milp(c=c, constraints=constraints, bounds=bounds,
                  integrality=integrality)

    if result.success:
        return result.x, result.fun
    else:
        return None, None

class Machine(object):
    def __init__(self, line):
        # line:
        # [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
        p = re.compile(r"(\(.*\)) \{(.*)\}")
        m = p.search(line)
        buttons_s = m.group(1).split(" ")
        buttons = []
        for button_s in buttons_s:
            bs = [int(b) for b in button_s[1:-1].split(",")]
            buttons.append(bs)
        self.buttons = buttons

        joltages_s = m.group(2)
        self.joltages = [int(j) for j in joltages_s.split(",")]

        # print(vars(self))

    def buttons_matrix(self):
        n = len(self.joltages)
        m = [
            [1 if i in button else 0 for i in range(n)]
            for button in self.buttons
        ]
        # print(m)
        return m

    def joltage_presses(self):
        buttons_matrix = self.buttons_matrix()
        A = np.transpose(np.array(buttons_matrix))
        b = np.array(self.joltages)
        x_opt, min_sum = solve_binary_system(A, b)
        return min_sum

if __name__ == '__main__':
    filename = sys.argv[1] if len(sys.argv) > 1 else "input.txt"
    with open(filename) as f:
        input = f.read()
    lines = input.strip().split("\n")
    ms = [Machine(line) for line in lines]

    jps = sum([m.joltage_presses() for m in ms])
    print("Part 2: ", jps)

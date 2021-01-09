#!/usr/bin/env python3
import unittest
from solution import *


class PasswordPhilosophyTests(unittest.TestCase):
    def test_is_valid_old(self):
        f = PasswordPhilosophy.is_valid_old

        self.assertEqual(f("1-3 a: abcde"), True)
        self.assertEqual(f("1-3 b: cdefg"), False)
        self.assertEqual(f("2-9 c: ccccccccc"), True)

    def test_is_valid_new(self):
        f = PasswordPhilosophy.is_valid_new

        self.assertEqual(f("1-3 a: abcde"), True)
        self.assertEqual(f("1-3 b: cdefg"), False)
        self.assertEqual(f("2-9 c: ccccccccc"), False)


if __name__ == '__main__':
    unittest.main()

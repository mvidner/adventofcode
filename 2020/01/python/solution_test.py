#!/usr/bin/env python3
import unittest
import solution


class ReportRepairTests(unittest.TestCase):
    def sample(self):
        return """
            1721
            979
            366
            299
            675
            1456
        """

    def test_pair(self):
        rr = solution.ReportRepair(self.sample())
        self.assertEqual(rr.find_pair(2020), (1721, 299))

    def test_triplet(self):
        rr = solution.ReportRepair(self.sample())
        self.assertEqual(rr.find_triplet(2020), (979, 366, 675))


if __name__ == '__main__':
    unittest.main()

#!/usr/bin/env -S uv run
# /// script
# dependencies = [
#     "numpy",
# ]
# ///
# See https://packaging.python.org/en/latest/specifications/inline-script-metadata/
# aka PEP 723

import sys
import re
from typing import Optional
import numpy as np

def bitmap_str(bitmap, true_char='#', false_char='.'):
    """Convert bitmap to string"""
    return '\n'.join(
        ''.join(true_char if pixel else false_char for pixel in row)
        for row in bitmap
    )

class Shape(object):
    @classmethod
    def from_text(cls, text):
        lines = text.strip().split("\n")
        rows = []
        for line in lines[1:]:
            row = [char == "#" for char in line]
            rows.append(row)

        pixels = np.asarray(rows, dtype=bool)
        return cls(pixels)

    def __init__(self, pixels: np.ndarray):
        self.pixels = pixels
        # self.dump()

    def __eq__(self, other):
        if not isinstance(other, Shape):
            return NotImplemented
        return self.pixels == other.pixels

    def __hash__(self):
        t = tuple(self.pixels.flat)
        # print(repr(t))
        h = hash(t)
        # print(h)
        return h

    def dump(self):
        print(bitmap_str(self.pixels), "\n")

    def get(self, y, x) -> bool:
        self_h, self_w = self.h_w()
        return 0<=y<self_h and 0<=x<self_w and self.pixels[y, x]

    def h_w(self):
        return tuple(self.pixels.shape)

    def symmetries(self) -> list["Shape"]:
        id = self
        fliplr = Shape(np.fliplr(self.pixels))
        flipud = Shape(np.flipud(self.pixels))
        flipsl = Shape(np.rot90(np.flipud(self.pixels)))
        flipbsl = Shape(np.rot90(np.fliplr(self.pixels)))
        r90 = Shape(np.rot90(self.pixels, 1))
        r180 = Shape(np.rot90(self.pixels, 2))
        r270 = Shape(np.rot90(self.pixels, 3))
        symlist = [id, r90, r180, r270, fliplr, flipsl, flipud, flipbsl]

        # ValueError: The truth value of an array with more than one element is ambiguous. Use a.any() or a.all()
        # symset = set(symlist)
        hlist = []
        symlist2 = []
        for s in symlist:
            h = hash(s)
            if not (h in hlist):
                hlist.append(h)
                symlist2.append(s)

        # print("SET")
        # for s in symlist2:
        #     s.dump()
        return symlist2

    def combine(self, other: "Shape", offset_x, offset_y) -> Optional["Shape"]:
        """
        Try combining other with self, where other is offset.
        Return None when the shapes would collide
        """
        self_h, self_w = self.pixels.shape
        other_h, other_w = other.pixels.shape

        min_y = min(0, offset_y)
        max_y_p1 = max(self_h, other_h + offset_y)
        result_h = max_y_p1 - min_y
        if offset_y >= 0:
            self_y_offset = 0
            other_y_offset = -offset_y
        else:
            self_y_offset = offset_y
            other_y_offset = 0

        min_x = min(0, offset_x)
        max_x_p1 = max(self_w, other_w + offset_x)
        result_w = max_x_p1 - min_x
        if offset_x >= 0:
            self_x_offset = 0
            other_x_offset = -offset_x
        else:
            self_x_offset = offset_x
            other_x_offset = 0

        result = np.zeros((result_h, result_w), dtype=bool)
        for y in range(result_h):
            for x in range(result_w):
                self_px = self.get(y + self_y_offset, x + self_x_offset)
                other_px = other.get(y + other_y_offset, x + other_x_offset)
                if self_px and other_px:
                    return None # pixel collision
                result[y, x] = self_px or other_px
        return Shape(result)

class Region(object):
    def __init__(self, line):
        region_pattern = re.compile(r"(\d+)x(\d+): (.*)")
        m = region_pattern.match(line)
        self.w = int(m.group(1))
        self.h = int(m.group(2))
        self.counts = [int(n_s) for n_s in m.group(3).split(" ")]

        print(vars(self))

class Solution(object):
    pass

class Packing(object):
    def __init__(self, text):
        paragraphs = text.split("\n\n")
        shape_header = re.compile(r"(\d+):")

        self.orig_shapes = []
        for shape_text in paragraphs[:-1]:
            self.orig_shapes.append(Shape.from_text(shape_text))

        self.shapes = []
        for s in self.orig_shapes:
            self.shapes.append(s.symmetries())

        self.regions = []
        for line in paragraphs[-1].strip().split("\n"):
            self.regions.append(Region(line))

        # print(vars(self))

    def stats(self):
        shape_areas = []
        shape_pixels = []
        for s in self.orig_shapes:
            h, w = s.h_w()
            shape_areas.append(h * w)
            px = np.count_nonzero(s.pixels)
            shape_pixels.append(px)
        print(shape_areas, shape_pixels)

        wont_fit = 0
        will_fit = 0
        undecided = 0
        for r in self.regions:
            print(f"Region {r.w}x{r.h} = {r.w*r.h}")
            print("  c:", r.counts, sum(r.counts))
            areas = 0
            pixels = 0
            for i in range(len(r.counts)):
                areas += r.counts[i] * shape_areas[i]
                pixels += r.counts[i] * shape_pixels[i]
            print("  a:", areas, "p:", pixels)
            if pixels > r.w * r.h:
                wont_fit += 1
            else:
                # reduced size
                # 3 is the tile bbox size
                rw = (r.w // 3) * 3
                rh = (r.h // 3) * 3
                if areas <= rw * rh:
                    will_fit += 1
                else:
                    undecided += 1
        print("Regions:", len(self.regions))
        print("Will fit:", will_fit, "Won't fit:", wont_fit)
        print("Undecided:", undecided)


    def demo(self):
        a = self.shapes[0][0]
        b = self.shapes[1][0]

        yo_min = -b.pixels.shape[0]
        xo_min = -b.pixels.shape[1]
        yo_max = a.pixels.shape[0]+1
        xo_max = a.pixels.shape[1]+1

        for y_offset in range(yo_min, yo_max):
            for x_offset in range(xo_min, xo_max):
                r = a.combine(b, x_offset, y_offset)
                if r:
                    r.dump()


if __name__ == '__main__':
    filename = sys.argv[1] if len(sys.argv) > 1 else "input.txt"
    with open(filename) as f:
        text = f.read()
    packing = Packing(text)
    packing.stats()

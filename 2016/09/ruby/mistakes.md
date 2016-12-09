This was the first day when I caught up with the unsolved puzzles, and got up
in time for the puzzle being published at 6am local time.

The general approach worked out well, but I made mistakes that cost me
debugging time:

- The Regexp matches were unanchored at first, so the first mentioned pattern
  always matched, later in the input string, even though the string was
  starting with another pattern.

- Then I used the wrong syntax for the anchor: it should be `\A`, not `\a`.
  Yeah, all other regex dialects use `^`, but in Ruby that can match the
  beginning of any line in the middle of the string.

- To get "the rest of the string" I used `s[skip_chars, -1]` whereas the
  correct form is `s[skip_chars .. -1]`. Doubly embarassing as I made the same
  mistake the day before.

- Using a number without converting it from String to
  Integer with String#to_i (sure, fixing that was quick).

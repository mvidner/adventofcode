- Not checking for unmatched input. Initially I did not implement the
  `jnz NUM1, NUM2` instruction, and the machine simply looped on and on.

- Off-by-one in the jump instruction, forgetting that I have already added 1
  at the beginning.

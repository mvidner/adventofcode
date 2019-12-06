require_relative "../solution"

lines = <<EOS
COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
EOS

describe "#total_num_orbits" do
  it "works for the example" do
    pairs = pairs_from_string(lines)
    expect(total_num_orbits(pairs)).to eq 42
  end
end

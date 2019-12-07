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

describe UniversalOrbitMap do
  describe "#total_num_orbits" do
    it "works for the example" do
      uom = described_class.new(lines)
      expect(uom.total_num_orbits).to eq 42
    end
  end
end

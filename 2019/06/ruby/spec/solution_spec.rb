require_relative "../solution"

describe UniversalOrbitMap do
  describe "#total_num_orbits" do
    let(:lines) do
      <<EOS
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
    end

    it "works for the example" do
      uom = described_class.new(lines)
      expect(uom.total_num_orbits).to eq 42
    end
  end

  describe "#orbital_transfers" do
    let(:lines) do
      <<EOS
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
K)YOU
I)SAN
EOS
    end

    it "works for the example" do
      uom = described_class.new(lines)
      expect(uom.orbital_transfers("YOU", "SAN")).to eq 4
    end
  end
end

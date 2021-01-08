require_relative "../solution"

describe ReportRepair do
  subject { described_class.new(sample) }

  let(:sample) do
    <<~TXT
    1721
    979
    366
    299
    675
    1456
    TXT
  end

  describe "#find_2020" do
    it "works for the sample" do
      expect(subject.find_2020).to eq 514_579
    end
  end

  describe "#find_triplet" do
    it "works for the sample" do
      expect(subject.find_triplet(2020)).to eq [979, 366, 675]
    end
  end
end

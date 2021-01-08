require_relative "../solution"

describe ReportRepair do
  subject { described_class.new(sample) }

  describe "#find_2020" do
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

    it "works for the sample" do
      expect(subject.find_2020).to eq 514579
    end
  end
end



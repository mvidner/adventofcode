require_relative "../solution"

describe MonitoringStation do
  subject { described_class.new(sample) }

  context "1st sample" do
    let(:sample) do
      <<~MAP
      .#..#
      .....
      #####
      ....#
      ...##
      MAP
    end

    describe "#visible?" do
      it "works" do
        expect(subject.visible?(3, 4, 0, 0)).to eq false # nothing there
        expect(subject.visible?(3, 4, 0, 2)).to eq true
        expect(subject.visible?(3, 4, 1, 0)).to eq false # occluded
        expect(subject.visible?(3, 4, 2, 2)).to eq true
      end
    end

    describe "count_visible" do
      it "works" do
        expect(subject.count_visible(1, 0)).to eq 7
        expect(subject.count_visible(0, 2)).to eq 6
        expect(subject.count_visible(5, 2)).to eq 5
        expect(subject.count_visible(3, 4)).to eq 8
      end
    end

    describe "#best_station" do
      it "works" do
        expect(subject.best_station).to eq [[3, 4], 8]
      end
    end
  end
end

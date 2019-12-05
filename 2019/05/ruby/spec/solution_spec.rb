require_relative "../solution"

describe "#argmode" do
  it "works" do
    ic = Intcode.new([])
    expect(ic.argmode(1002, 0)).to eq 0
    expect(ic.argmode(1002, 1)).to eq 1
    expect(ic.argmode(1002, 2)).to eq 0
  end
end

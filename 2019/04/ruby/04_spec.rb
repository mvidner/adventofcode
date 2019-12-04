require_relative "solution"

describe "#valid_try?" do
  it "is true for good samples" do
    expect(valid_try?(111111)).to eq true
  end

  it "is false for bad samples" do
    expect(valid_try?(223450)).to eq false
    expect(valid_try?(123789)).to eq false
  end
end

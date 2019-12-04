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

describe "#more_valid_try?" do
  it "is true for good samples" do
    expect(more_valid_try?(112233)).to eq true
    expect(more_valid_try?(111122)).to eq true
  end

  it "is false for bad samples" do
    expect(more_valid_try?(123444)).to eq false
  end
end

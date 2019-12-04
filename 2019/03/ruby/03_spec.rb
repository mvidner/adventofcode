require_relative "solution"

sample1 = "R75,D30,R83,U83,L12,D49,R71,U7,L72\n" \
          "U62,R66,U55,R34,D71,R55,D58,R83"
sample2 = "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51\n" \
          "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"

describe "#crossing_distance" do
  it "works for sample 1" do
    expect(crossing_distance(sample1)).to eq(159)
  end

  it "works for sample 2" do
    expect(crossing_distance(sample2)).to eq(135)
  end
end

describe "#crossing_steps" do
  it "works for sample 1" do
    expect(crossing_steps(sample1)).to eq(610)
  end

  it "works for sample 2" do
    expect(crossing_steps(sample2)).to eq(410)
  end
end

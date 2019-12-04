require_relative "solution"

describe "#crossing_distance" do
  it "works for sample 1" do
    input = "R75,D30,R83,U83,L12,D49,R71,U7,L72\n" \
            "U62,R66,U55,R34,D71,R55,D58,R83"
    expect(crossing_distance(input)).to eq(159)
  end

  it "works for sample 2" do
    input = "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51\n" \
            "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
    expect(crossing_distance(input)).to eq(135)
  end
end

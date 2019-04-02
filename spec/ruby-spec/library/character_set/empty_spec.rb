describe "CharacterSet#empty?" do
  it "returns true if self is empty" do
    CharacterSet[].empty?.should be true
    CharacterSet[1].empty?.should be false
    CharacterSet[1,2,3].empty?.should be false
  end
end

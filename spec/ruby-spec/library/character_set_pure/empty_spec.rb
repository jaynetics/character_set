describe "CharacterSet::Pure#empty?" do
  it "returns true if self is empty" do
    CharacterSet::Pure[].empty?.should be true
    CharacterSet::Pure[1].empty?.should be false
    CharacterSet::Pure[1,2,3].empty?.should be false
  end
end

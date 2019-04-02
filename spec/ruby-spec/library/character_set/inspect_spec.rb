describe "CharacterSet#inspect" do
  it "returns a String representation of self" do
    CharacterSet[].inspect.should be_kind_of(String)
    CharacterSet[1, 2, 3].inspect.should be_kind_of(String)
    CharacterSet["1", "2", "3"].inspect.should be_kind_of(String)
  end
end

describe "CharacterSet::Pure#inspect" do
  it "returns a String representation of self" do
    CharacterSet::Pure[].inspect.should be_kind_of(String)
    CharacterSet::Pure[1, 2, 3].inspect.should be_kind_of(String)
    CharacterSet::Pure["1", "2", "3"].inspect.should be_kind_of(String)
  end
end

shared_examples :sorted_set_1_intersection do |method|
  before :each do
    @set = CharacterSet::Pure["a", "b", "c"]
  end

  it "returns a new CharacterSet::Pure containing only elements shared by self and the passed Enumerable" do
    @set.send(method, CharacterSet::Pure["b", "c", "d", "e"]).should == CharacterSet::Pure["b", "c"]
    @set.send(method, ["b", "c", "d"]).should == CharacterSet::Pure["b", "c"]
  end

  it "raises an ArgumentError when passed a non-Enumerable" do
    lambda { @set.send(method, 1) }.should raise_error(ArgumentError)
    lambda { @set.send(method, Object.new) }.should raise_error(ArgumentError)
  end
end

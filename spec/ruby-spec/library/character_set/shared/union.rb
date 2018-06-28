shared_examples :sorted_set_0_union do |method|
  before :each do
    @set = CharacterSet["a", "b", "c"]
  end

  it "returns a new CharacterSet containing all elements of self and the passed Enumerable" do
    @set.send(method, CharacterSet["b", "d", "e"]).should == CharacterSet["a", "b", "c", "d", "e"]
    @set.send(method, ["b", "e"]).should == CharacterSet["a", "b", "c", "e"]
  end

  it "raises an ArgumentError when passed a non-Enumerable" do
    lambda { @set.send(method, 1) }.should raise_error(ArgumentError)
    lambda { @set.send(method, Object.new) }.should raise_error(ArgumentError)
  end
end

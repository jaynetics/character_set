shared_examples :sorted_set_0_intersection do |method|
  before :each do
    @set = CharacterSet["a", "b", "c"]
  end

  it "returns a new CharacterSet containing only elements shared by self and the passed Enumerable" do
    @set.send(method, CharacterSet["b", "c", "d", "e"]).should == CharacterSet["b", "c"]
    @set.send(method, ["b", "c", "d"]).should == CharacterSet["b", "c"]
  end

  it "raises an ArgumentError when passed a non-Enumerable" do
    lambda { @set.send(method, 1) }.should raise_error(ArgumentError)
    lambda { @set.send(method, Object.new) }.should raise_error(ArgumentError)
  end
end

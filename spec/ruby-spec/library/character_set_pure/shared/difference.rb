shared_examples :sorted_set_1_difference do |method|
  before :each do
    @set = CharacterSet::Pure["a", "b", "c"]
  end

  it "returns a new CharacterSet::Pure containing self's elements excluding the elements in the passed Enumerable" do
    @set.send(method, CharacterSet::Pure["a", "b"]).should == CharacterSet::Pure["c"]
    @set.send(method, ["b", "c"]).should == CharacterSet::Pure["a"]
  end

  it "raises an ArgumentError when passed a non-Enumerable" do
    lambda { @set.send(method, 1) }.should raise_error(ArgumentError)
    lambda { @set.send(method, Object.new) }.should raise_error(ArgumentError)
  end
end

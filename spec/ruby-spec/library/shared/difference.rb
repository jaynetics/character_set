shared_examples :sorted_set_difference do |variant, method|
  before :each do
    @set = variant["a", "b", "c"]
  end

  it "returns a new variant containing self's elements excluding the elements in the passed Enumerable" do
    @set.send(method, variant["a", "b"]).should == variant["c"]
    @set.send(method, ["b", "c"]).should == variant["a"]
  end

  it "raises an ArgumentError when passed a non-Enumerable" do
    lambda { @set.send(method, 1) }.should raise_error(ArgumentError)
    lambda { @set.send(method, Object.new) }.should raise_error(ArgumentError)
  end
end

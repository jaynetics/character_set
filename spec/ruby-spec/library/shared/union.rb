shared_examples :sorted_set_union do |variant, method|
  before :each do
    @set = variant["a", "b", "c"]
  end

  it "returns a new variant containing all elements of self and the passed Enumerable" do
    @set.send(method, variant["b", "d", "e"]).should == variant["a", "b", "c", "d", "e"]
    @set.send(method, ["b", "e"]).should == variant["a", "b", "c", "e"]
  end

  it "raises an ArgumentError when passed a non-Enumerable" do
    lambda { @set.send(method, 1) }.should raise_error(ArgumentError)
    lambda { @set.send(method, Object.new) }.should raise_error(ArgumentError)
  end
end

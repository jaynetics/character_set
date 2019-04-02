shared_examples :sorted_set_intersection do |variant, method|
  before :each do
    @set = variant["a", "b", "c"]
  end

  it "returns a new variant containing only elements shared by self and the passed Enumerable" do
    @set.send(method, variant["b", "c", "d", "e"]).should == variant["b", "c"]
    @set.send(method, ["b", "c", "d"]).should == variant["b", "c"]
  end

  it "raises an ArgumentError when passed a non-Enumerable" do
    lambda { @set.send(method, 1) }.should raise_error(ArgumentError)
    lambda { @set.send(method, Object.new) }.should raise_error(ArgumentError)
  end
end

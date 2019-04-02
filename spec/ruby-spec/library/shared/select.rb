shared_examples :sorted_set_select_bang do |variant, method|
  before :each do
    @set = variant[1, 2, 3]
  end

  it "yields each Object in self in sorted order" do
    res = []
    @set.send(method) { |x| res << x }
    res.should == [1, 2, 3].sort
  end

  it "keeps every element from self for which the passed block returns true" do
    @set.send(method) { |x| x == 3 }
    @set.to_a.should == [3]
  end

  it "returns self when self was modified" do
    @set.send(method) { false }.should equal(@set)
  end

  it "returns nil when self was not modified" do
    @set.send(method) { true }.should be_nil
  end

  it "returns an Enumerator when passed no block" do
    enum = @set.send(method)
    enum.should be_an_instance_of(Enumerator)

    enum.each { |x| x == 3 }
    @set.to_a.should == [3]
  end
end

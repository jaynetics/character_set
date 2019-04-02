describe "CharacterSet::Pure#delete_if" do
  before :each do
    @set = CharacterSet::Pure[1, 2, 3]
  end

  it "yields each Object in self in sorted order" do
    ret = []
    @set.delete_if { |x| ret << x }
    ret.should == [1, 2, 3].sort
  end

  it "deletes every element from self for which the passed block returns true" do
    @set.delete_if { |x| x != 3 }
    @set.size.should eql(1)

    @set.should_not include(1)
    @set.should_not include(2)
    @set.should include(3)
  end

  it "returns self" do
    @set.delete_if { |x| x }.should equal(@set)
  end

  it "returns an Enumerator when passed no block" do
    enum = @set.delete_if
    enum.should be_an_instance_of(Enumerator)

    enum.each { |x| x != 3 }

    @set.should_not include(1)
    @set.should_not include(2)
    @set.should include(3)
  end
end

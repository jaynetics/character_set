describe "CharacterSet::Pure#keep_if" do
  before :each do
    @set = CharacterSet::Pure[1, 2, 3]
  end

  it "yields each Object in self in sorted order" do
    ret = []
    @set.keep_if { |x| ret << x }
    ret.should == [1, 2, 3].sort
  end

  it "keeps every element from self for which the passed block returns true" do
    @set.keep_if { |x| x == 3 }
    @set.to_a.should == [3]
  end

  it "returns self" do
    @set.keep_if {}.should equal(@set)
  end

  it "returns an Enumerator when passed no block" do
    enum = @set.keep_if
    enum.should be_an_instance_of(Enumerator)

    enum.each { |x| x == 3 }
    @set.to_a.should == [3]
  end
end

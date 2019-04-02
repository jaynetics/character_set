describe "CharacterSet#each" do
  before :each do
    @set = CharacterSet[1, 2, 3]
  end

  it "yields each Object in self in sorted order" do
    ret = []
    CharacterSet[1, 2, 3].each { |x| ret << x }
    ret.should == [1, 2, 3].sort
  end

  it "returns self" do
    @set.each { |x| x }.should equal(@set)
  end

  it "returns an Enumerator when not passed a block" do
    enum = @set.each

    ret = []
    enum.each { |x| ret << x }
    ret.sort.should == [1, 2, 3]
  end
end

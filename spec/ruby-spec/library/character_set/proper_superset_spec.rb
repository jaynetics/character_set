describe "CharacterSet#proper_superset?" do
  before :each do
    @set = CharacterSet[1, 2, 3, 4]
  end

  it "returns true if passed a CharacterSet that self is a proper superset of" do
    @set.proper_superset?(CharacterSet[]).should be true
    CharacterSet[1, 2, 3].proper_superset?(CharacterSet[]).should be true
    CharacterSet["a", "b", "c"].proper_superset?(CharacterSet[]).should be true

    @set.proper_superset?(CharacterSet[1, 2, 3]).should be true
    @set.proper_superset?(CharacterSet[1, 3]).should be true
    @set.proper_superset?(CharacterSet[1, 2]).should be true
    @set.proper_superset?(CharacterSet[1]).should be true

    @set.proper_superset?(CharacterSet[5]).should be false
    @set.proper_superset?(CharacterSet[1, 5]).should be false
    @set.proper_superset?(CharacterSet[0]).should be false

    @set.proper_superset?(@set).should be false
    CharacterSet[].proper_superset?(CharacterSet[]).should be false
  end

  it "raises an ArgumentError when passed a non-CharacterSet" do
    lambda { CharacterSet[].proper_superset?([]) }.should raise_error(ArgumentError)
    lambda { CharacterSet[].proper_superset?(1) }.should raise_error(ArgumentError)
    lambda { CharacterSet[].proper_superset?(0) }.should raise_error(ArgumentError)
    lambda { CharacterSet[].proper_superset?(Object.new) }.should raise_error(ArgumentError)
  end
end

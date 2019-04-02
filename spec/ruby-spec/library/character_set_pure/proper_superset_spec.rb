describe "CharacterSet::Pure#proper_superset?" do
  before :each do
    @set = CharacterSet::Pure[1, 2, 3, 4]
  end

  it "returns true if passed a CharacterSet::Pure that self is a proper superset of" do
    @set.proper_superset?(CharacterSet::Pure[]).should be true
    CharacterSet::Pure[1, 2, 3].proper_superset?(CharacterSet::Pure[]).should be true
    CharacterSet::Pure["a", "b", "c"].proper_superset?(CharacterSet::Pure[]).should be true

    @set.proper_superset?(CharacterSet::Pure[1, 2, 3]).should be true
    @set.proper_superset?(CharacterSet::Pure[1, 3]).should be true
    @set.proper_superset?(CharacterSet::Pure[1, 2]).should be true
    @set.proper_superset?(CharacterSet::Pure[1]).should be true

    @set.proper_superset?(CharacterSet::Pure[5]).should be false
    @set.proper_superset?(CharacterSet::Pure[1, 5]).should be false
    @set.proper_superset?(CharacterSet::Pure[0]).should be false

    @set.proper_superset?(@set).should be false
    CharacterSet::Pure[].proper_superset?(CharacterSet::Pure[]).should be false
  end

  it "raises an ArgumentError when passed a non-CharacterSet::Pure" do
    lambda { CharacterSet::Pure[].proper_superset?([]) }.should raise_error(ArgumentError)
    lambda { CharacterSet::Pure[].proper_superset?(1) }.should raise_error(ArgumentError)
    lambda { CharacterSet::Pure[].proper_superset?(0) }.should raise_error(ArgumentError)
    lambda { CharacterSet::Pure[].proper_superset?(Object.new) }.should raise_error(ArgumentError)
  end
end

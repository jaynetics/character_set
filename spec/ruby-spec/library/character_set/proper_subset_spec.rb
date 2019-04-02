describe "CharacterSet#proper_subset?" do
  before :each do
    @set = CharacterSet[1, 2, 3, 4]
  end

  it "returns true if passed a CharacterSet that self is a proper subset of" do
    CharacterSet[].proper_subset?(@set).should be true
    CharacterSet[].proper_subset?(CharacterSet[1, 2, 3]).should be true
    CharacterSet[].proper_subset?(CharacterSet["a", "b", "c"]).should be true

    CharacterSet[1, 2, 3].proper_subset?(@set).should be true
    CharacterSet[1, 3].proper_subset?(@set).should be true
    CharacterSet[1, 2].proper_subset?(@set).should be true
    CharacterSet[1].proper_subset?(@set).should be true

    CharacterSet[5].proper_subset?(@set).should be false
    CharacterSet[1, 5].proper_subset?(@set).should be false
    CharacterSet[0].proper_subset?(@set).should be false

    @set.proper_subset?(@set).should be false
    CharacterSet[].proper_subset?(CharacterSet[]).should be false
  end

  it "raises an ArgumentError when passed a non-CharacterSet" do
    lambda { CharacterSet[].proper_subset?([]) }.should raise_error(ArgumentError)
    lambda { CharacterSet[].proper_subset?(1) }.should raise_error(ArgumentError)
    lambda { CharacterSet[].proper_subset?(0) }.should raise_error(ArgumentError)
    lambda { CharacterSet[].proper_subset?(Object.new) }.should raise_error(ArgumentError)
  end
end

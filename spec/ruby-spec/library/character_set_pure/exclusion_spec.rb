describe "CharacterSet::Pure#^" do
  before :each do
    @set = CharacterSet::Pure[1, 2, 3, 4]
  end

  it "returns a new CharacterSet::Pure containing elements that are not in both self and the passed Enumerable" do
    (@set ^ CharacterSet::Pure[3, 4, 5]).should == CharacterSet::Pure[1, 2, 5]
    (@set ^ [3, 4, 5]).should == CharacterSet::Pure[1, 2, 5]
  end

  it "raises an ArgumentError when passed a non-Enumerable" do
    lambda { @set ^ 3 }.should raise_error(ArgumentError)
    lambda { @set ^ Object.new }.should raise_error(ArgumentError)
  end
end

describe "CharacterSet[]" do
  it "returns a new CharacterSet populated with the passed Objects" do
    set = CharacterSet[1, 2, 3]

    set.instance_of?(CharacterSet).should be true
    set.size.should eql(3)

    set.should include(1)
    set.should include(2)
    set.should include(3)
  end
end

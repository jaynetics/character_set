describe "CharacterSet::Pure[]" do
  it "returns a new CharacterSet::Pure populated with the passed Objects" do
    set = CharacterSet::Pure[1, 2, 3]

    set.instance_of?(CharacterSet::Pure).should be true
    set.size.should eql(3)

    set.should include(1)
    set.should include(2)
    set.should include(3)
  end
end

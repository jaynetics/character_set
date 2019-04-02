describe "CharacterSet::Pure#hash" do
  it "is static" do
    CharacterSet::Pure[].hash.should == CharacterSet::Pure[].hash
    CharacterSet::Pure[1, 2, 3].hash.should == CharacterSet::Pure[1, 2, 3].hash
    CharacterSet::Pure["a", "b", "c"].hash.should == CharacterSet::Pure["c", "b", "a"].hash

    CharacterSet::Pure[].hash.should_not == CharacterSet::Pure[1, 2, 3].hash
    CharacterSet::Pure[1, 2, 3].hash.should_not == CharacterSet::Pure["a", "b", "c"].hash
  end
end

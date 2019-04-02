describe "CharacterSet#eql?" do
  it "returns true when the passed argument is a CharacterSet and contains the same elements" do
    CharacterSet[].should eql(CharacterSet[])
    CharacterSet[1, 2, 3].should eql(CharacterSet[1, 2, 3])
    CharacterSet[1, 2, 3].should eql(CharacterSet[3, 2, 1])

#    CharacterSet["a", :b, ?c].should eql(CharacterSet[?c, :b, "a"])

    CharacterSet[1, 2, 3].should_not eql(CharacterSet[0, 2, 3])
    CharacterSet[1, 2, 3].should_not eql(CharacterSet[2, 3])
    CharacterSet[1, 2, 3].should_not eql(CharacterSet[])
  end
end

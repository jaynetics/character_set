# copied and adapted from ruby-spec

shared_examples :character_set_classify do |variant|
  it "yields each Object in self in sorted order" do
    res = []
    variant[1, 2, 3, 4].classify { |x| res << x }
    res.should == [1, 2, 3, 4].sort
  end

  it "returns an Enumerator when passed no block" do
    enum = variant[1, 2, 3, 4].classify
    enum.should be_an_instance_of(Enumerator)

    classified = enum.each(&:odd?)
    classified.should == { true => variant[1, 3], false => variant[2, 4] }
  end

  it "classifies the Objects in self based on the block's return value" do
    classified = variant[1, 2, 3, 4].classify(&:odd?)
    classified.should == { true => variant[1, 3], false => variant[2, 4] }
  end
end

describe "CharacterSet#classify" do
  it_behaves_like :character_set_classify, CharacterSet
end

describe "CharacterSet::Pure#classify" do
  it_behaves_like :character_set_classify, CharacterSet::Pure
end

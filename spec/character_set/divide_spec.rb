# copied and adapted from ruby-spec

shared_examples :character_set_divide do |variant|
  it "divides self into a set of subsets based on the blocks return values" do
    set = variant[1, 2, 3, 4, 5].divide(&:odd?)
    set.map { |x| x.to_a }.to_a.sort.should == [[1, 3, 5], [2, 4]]
  end

  it "yields each Object in self in sorted order" do
    ret = []
    variant[1, 2, 3, 4, 5].divide { |x| ret << x }
    ret.should == [1, 2, 3, 4, 5].sort
  end

  describe "when passed a block with an arity of 2" do
    it "divides self into a set of subsets based on the blocks return values" do
      set = variant[1, 3, 4, 6, 9, 10, 11].divide { |x, y| (x - y).abs == 1 }
      set.map { |x| x.to_a }.to_a.sort.should == [[1], [3, 4], [6], [9, 10, 11]]
    end

    it "yields each two Objects to the block" do
      ret = []
      variant[1, 2].divide { |x, y| ret << [x, y] }
      ret.should == [[1, 1], [1, 2], [2, 1], [2, 2]]
    end
  end
end

describe "CharacterSet#divide" do
  it_behaves_like :character_set_divide, CharacterSet
end

describe "CharacterSet::Pure#divide" do
  it_behaves_like :character_set_divide, CharacterSet::Pure
end

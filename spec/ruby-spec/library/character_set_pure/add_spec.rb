require_relative '../shared/add'

describe "CharacterSet::Pure#add" do
  it_behaves_like :sorted_set_add, CharacterSet::Pure, :add

  it "takes only values which responds <=>" do
    obj = double('no_comparison_operator')
    obj.stub(:respond_to?).with(:<=>).and_return(false)
    lambda { CharacterSet::Pure[0].add(obj) }.should raise_error(ArgumentError)
  end

  it "raises on incompatible <=> comparison" do
    # Use #to_a here as elements are sorted only when needed.
    # Therefore the <=> incompatibility is only noticed on sorting.
    lambda { CharacterSet::Pure['1', '2'].add(:foo).to_a }.should raise_error(ArgumentError)
  end
end

describe "CharacterSet::Pure#add?" do
  before :each do
    @set = CharacterSet::Pure.new
  end

  it "adds the passed Object to self" do
    @set.add?(0)
    @set.should include(0)
  end

  it "returns self when the Object has not yet been added to self" do
    @set.add?(0).should equal(@set)
  end

  it "returns nil when the Object has already been added to self" do
    @set.add?(0)
    @set.add?(0).should be_nil
  end
end

shared_examples :sorted_set_0_add do |method|
  before :each do
    @set = CharacterSet.new
  end

  it "adds the passed Object to self" do
    @set.send(method, 0)
    @set.should include(0)
  end

  it "returns self" do
    @set.send(method, 0).should equal(@set)
  end
end

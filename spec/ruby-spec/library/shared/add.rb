shared_examples :sorted_set_add do |variant, method|
  before :each do
    @set = variant.new
  end

  it "adds the passed Object to self" do
    @set.send(method, 0)
    @set.should include(0)
  end

  it "returns self" do
    @set.send(method, 0).should equal(@set)
  end
end

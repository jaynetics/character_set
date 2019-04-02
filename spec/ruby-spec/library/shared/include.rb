shared_examples :sorted_set_include do |variant, method|
  it "returns true when self contains the passed Object" do
    set = variant["a", "b", "c"]
    set.send(method, "a").should be true
    set.send(method, "e").should be false
  end
end

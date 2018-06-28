shared_examples :sorted_set_0_include do |method|
  it "returns true when self contains the passed Object" do
    set = CharacterSet["a", "b", "c"]
    set.send(method, "a").should be true
    set.send(method, "e").should be false
  end
end

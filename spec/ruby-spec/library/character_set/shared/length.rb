shared_examples :sorted_set_0_length do |method|
  it "returns the number of elements in the set" do
    set = CharacterSet["a", "b", "c"]
    set.send(method).should == 3
  end
end

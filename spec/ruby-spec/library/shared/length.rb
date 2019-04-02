shared_examples :sorted_set_length do |variant, method|
  it "returns the number of elements in the set" do
    set = variant["a", "b", "c"]
    set.send(method).should == 3
  end
end

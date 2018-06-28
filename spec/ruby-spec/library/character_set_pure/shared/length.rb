shared_examples :sorted_set_1_length do |method|
  it "returns the number of elements in the set" do
    set = CharacterSet::Pure["a", "b", "c"]
    set.send(method).should == 3
  end
end

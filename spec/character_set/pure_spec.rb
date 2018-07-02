describe CharacterSet::Pure do
  it 'uses only Ruby implementations' do
    (CharacterSet::Pure.methods - Object.methods)
      .map { |name| CharacterSet::Pure.method(name) }
      .each do |class_method|
      expect(class_method.source_location).not_to be_nil
      expect(class_method.source_location[0]).to end_with '.rb'
    end

    (CharacterSet::Pure.instance_methods - Object.instance_methods)
      .map { |name| CharacterSet::Pure.instance_method(name) }
      .each do |instance_method|
      expect(instance_method.source_location).not_to be_nil
      expect(instance_method.source_location[0]).to end_with '.rb'
    end
  end
end

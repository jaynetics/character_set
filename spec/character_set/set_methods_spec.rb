RSpec.describe CharacterSet::SetMethods do
  it 'accepts Integer and String args for #add' do
    set = CharacterSet[97]
    set.add(98)
    set.add('c')
    expect(set).to eq CharacterSet[97, 98, 99]
  end

  it 'accepts Integer and String args for #add?' do
    set = CharacterSet[97]
    expect(set.add?(98)).to  be_truthy
    expect(set.add?(98)).to  be_falsy
    expect(set.add?('b')).to be_falsy
    expect(set.add?('c')).to be_truthy
    expect(set).to eq CharacterSet[97, 98, 99]
  end

  it 'accepts Integer and String args for #delete' do
    set = CharacterSet[97, 98, 99]
    set.delete(98)
    set.delete('c')
    expect(set).to eq CharacterSet[97]
  end

  it 'accepts Integer and String args for #delete?' do
    set = CharacterSet[97, 98, 99]
    expect(set.delete?(98)).to  be_truthy
    expect(set.delete?(98)).to  be_falsy
    expect(set.delete?('b')).to be_falsy
    expect(set.delete?('c')).to be_truthy
    expect(set).to eq CharacterSet[97]
  end

  %w[include? member?].each do |method_name|
    it "accepts Integer and String args for ##{method_name}" do
      expect(CharacterSet[97].send(method_name, 97)).to  be true
      expect(CharacterSet[97].send(method_name, 'a')).to be true
      expect(CharacterSet[97].send(method_name, 98)).to  be false
      expect(CharacterSet[97].send(method_name, 'b')).to be false
    end
  end
end

shared_examples :character_set_set_method_adapters do |variant|
  it 'accepts Integer and String args for #add' do
    expect(variant[97].add(97)).to  eq variant[97]
    expect(variant[97].add('a')).to eq variant[97]
    expect(variant[97].add(98)).to  eq variant[97, 98]
    expect(variant[97].add('b')).to eq variant[97, 98]
  end

  it 'accepts Integer and String args for #<<' do
    expect(variant[97].<<(97)).to  eq variant[97]
    expect(variant[97].<<('a')).to eq variant[97]
    expect(variant[97].<<(98)).to  eq variant[97, 98]
    expect(variant[97].<<('b')).to eq variant[97, 98]
  end

  it 'accepts Integer and String args for #add?' do
    expect(variant[97].add?(97)).to  eq nil
    expect(variant[97].add?('a')).to eq nil
    expect(variant[97].add?(98)).to  eq variant[97, 98]
    expect(variant[97].add?('b')).to eq variant[97, 98]
  end

  it 'accepts Integer and String args for #delete' do
    expect(variant[97].delete(97)).to  eq variant[]
    expect(variant[97].delete('a')).to eq variant[]
    expect(variant[97].delete(98)).to  eq variant[97]
    expect(variant[97].delete('b')).to eq variant[97]
  end

  it 'accepts Integer and String args for #delete?' do
    expect(variant[97].delete?(97)).to  eq variant[]
    expect(variant[97].delete?('a')).to eq variant[]
    expect(variant[97].delete?(98)).to  eq nil
    expect(variant[97].delete?('b')).to eq nil
  end

  it 'accepts Integer and String args for #include?' do
    expect(variant[97].include?(97)).to  be true
    expect(variant[97].include?('a')).to be true
    expect(variant[97].include?(98)).to  be false
    expect(variant[97].include?('b')).to be false
  end

  it 'accepts Integer and String args for #member?' do
    expect(variant[97].member?(97)).to  be true
    expect(variant[97].member?('a')).to be true
    expect(variant[97].member?(98)).to  be false
    expect(variant[97].member?('b')).to be false
  end
end

describe CharacterSet do
  it_behaves_like :character_set_set_method_adapters, CharacterSet
end

describe CharacterSet::Pure do
  it_behaves_like :character_set_set_method_adapters, CharacterSet::Pure
end

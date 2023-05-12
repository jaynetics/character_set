shared_examples :character_set_join do |variant|
  it 'joins the characters in the set to a string' do
    expect(variant[97].join).to eq 'a'
    expect(variant[97].join('--')).to eq 'a'
    expect(variant[97, 98, 99].join).to eq 'abc'
    expect(variant[97, 98, 99].join('--')).to eq 'a--b--c'
  end

  it 'raises TypeError for invalid separators' do
    expect { variant[97, 98, 99].join(0) }.to raise_error(TypeError)
  end
end

describe "CharacterSet#join" do
  it_behaves_like :character_set_join, CharacterSet
end

describe "CharacterSet::Pure#join" do
  it_behaves_like :character_set_join, CharacterSet::Pure
end

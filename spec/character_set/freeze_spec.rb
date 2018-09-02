shared_examples :character_set_freeze do |variant|
  it 'marks the character set as frozen' do
    set = variant[97, 98, 99]
    expect { set.freeze }.to change { set.frozen? }.from(false).to(true)
  end

  it 'returns the character set itself' do
    set = variant[97, 98, 99]
    expect(set.freeze).to equal set
  end
end

describe "CharacterSet#freeze" do
  it_behaves_like :character_set_freeze, CharacterSet
end

describe "CharacterSet::Pure#freeze" do
  it_behaves_like :character_set_freeze, CharacterSet::Pure
end

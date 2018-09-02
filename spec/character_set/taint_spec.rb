shared_examples :character_set_taint do |variant|
  it 'marks the character set as tainted' do
    set = variant[97, 98, 99]
    expect { set.taint }.to change { set.tainted? }.from(false).to(true)
  end

  it 'returns the character set itself' do
    set = variant[97, 98, 99]
    expect(set.taint).to equal set
  end
end

describe "CharacterSet#taint" do
  it_behaves_like :character_set_taint, CharacterSet
end

describe "CharacterSet::Pure#taint" do
  it_behaves_like :character_set_taint, CharacterSet::Pure
end

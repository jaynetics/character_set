shared_examples :character_set_each do |variant|
  it 'provides an Enumerator whose size reflects subsequent mutations' do
    set = variant[1]
    enumerator = set.each
    set.add(2)
    expect(enumerator.size).to eq 2
  end
end

describe 'CharacterSet#each' do
  it_behaves_like :character_set_each, CharacterSet
end

describe 'CharacterSet::Pure#each' do
  it_behaves_like :character_set_each, CharacterSet::Pure
end

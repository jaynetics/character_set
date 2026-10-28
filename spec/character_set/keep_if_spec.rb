shared_examples :character_set_keep_if do |variant|
  it 'provides an Enumerator whose size reflects subsequent mutations' do
    set = variant[1]
    enumerator = set.keep_if
    set.add(2)
    expect(enumerator.size).to eq 2
  end
end

describe 'CharacterSet#keep_if' do
  it_behaves_like :character_set_keep_if, CharacterSet
end

describe 'CharacterSet::Pure#keep_if' do
  it_behaves_like :character_set_keep_if, CharacterSet::Pure
end

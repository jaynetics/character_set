shared_examples :character_set_marshal do |variant|
  it 'dumps and loads a CharactarSet' do
    dump = Marshal.dump(variant[97, 98, 99])
    expect(Marshal.load(dump)).to eq variant[97, 98, 99]
  end
end

describe "CharacterSet#\{marshal_dump,marshal_load}" do
  it_behaves_like :character_set_marshal, CharacterSet
end

describe "CharacterSet::Pure#\{marshal_dump,marshal_load}" do
  it_behaves_like :character_set_marshal, CharacterSet::Pure
end

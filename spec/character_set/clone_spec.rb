shared_examples :character_set_clone do |variant|
  it 'returns a new set with the same codepoints' do
    expect(variant[97, 98, 99].clone).to eq variant[97, 98, 99]
    orig = variant[97, 98, 99]
    expect(orig.clone.object_id).not_to eq(orig.object_id)
  end
end

describe "CharacterSet#clone" do
  it_behaves_like :character_set_clone, CharacterSet
end

describe "CharacterSet::Pure#clone" do
  it_behaves_like :character_set_clone, CharacterSet::Pure
end

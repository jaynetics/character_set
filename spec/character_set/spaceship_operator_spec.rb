shared_examples :character_set_spaceship_operator do |variant|
  it 'compares left and right' do
    expect(variant[97] <=> variant[97]).to eq(0) # rubocop:disable Lint
    expect(variant[97, 98] <=> variant[97]).to eq(1)
    expect(variant[97] <=> variant[97, 98]).to eq(-1)
  end
end

describe "CharacterSet#spaceship_operator" do
  it_behaves_like :character_set_spaceship_operator, CharacterSet
end

describe "CharacterSet::Pure#spaceship_operator" do
  it_behaves_like :character_set_spaceship_operator, CharacterSet::Pure
end

shared_examples :character_set_secure_token do |variant|
  it 'generates a string of random characters from the set' do
    expect(variant[97, 98, 99].secure_token).to be_a String
    expect(variant[97, 98, 99].secure_token).to match /\A[abc]+\z/
  end

  it 'has a default length of 32' do
    expect(variant[97].secure_token).to eq 'a' * 32
  end

  it 'takes a length argument' do
    expect(variant[97].secure_token(1)).to eq 'a'
  end

  it 'is aliased as #random_token' do
    expect(variant[97].random_token(1)).to eq 'a'
  end
end

describe 'CharacterSet#secure_token' do
  it_behaves_like :character_set_secure_token, CharacterSet
end

describe 'CharacterSet::Pure#secure_token' do
  it_behaves_like :character_set_secure_token, CharacterSet::Pure
end

shared_examples :character_set_untaint do |variant|
  it 'marks the character set as untainted' do
    set = variant[97, 98, 99]
    set.taint
    expect { set.untaint }.to change { set.tainted? }.from(true).to(false)
  end

  it 'returns the character set itself' do
    set = variant[97, 98, 99]
    expect(set.untaint).to equal set
  end
end

describe "CharacterSet#untaint" do
  it_behaves_like :character_set_untaint, CharacterSet
end

describe "CharacterSet::Pure#untaint" do
  it_behaves_like :character_set_untaint, CharacterSet::Pure
end

shared_examples :character_set_to_s do |variant|
  it 'calls CharacterSet::Writer::write' do
    expect(CharacterSet::Writer).to receive(:write).and_return(42)
    expect(variant[].to_s).to eq 42
  end
end

describe "CharacterSet#to_s" do
  it_behaves_like :character_set_to_s, CharacterSet
end

describe "CharacterSet::Pure#to_s" do
  it_behaves_like :character_set_to_s, CharacterSet::Pure
end

shared_examples :character_set_initialize do |variant|
  it 'gets data via Parser::codepoints_from_enumerable' do
    expect(CharacterSet::Parser)
      .to receive(:codepoints_from_enumerable)
      .and_return([42])

    expect(variant.new('foo').to_a).to eq [42]
  end

  it 'gets called by ::[]' do
    expect(CharacterSet::Parser)
      .to receive(:codepoints_from_enumerable)
      .and_return([42])

    expect(variant['foo'].to_a).to eq [42]
  end
end

describe "CharacterSet#initialize" do
  it_behaves_like :character_set_initialize, CharacterSet
end

describe "CharacterSet::Pure#initialize" do
  it_behaves_like :character_set_initialize, CharacterSet::Pure
end

shared_examples :character_set_parse do |variant|
  it 'gets data via Parser::codepoints_from_bracket_expression' do
    expect(CharacterSet::Parser)
      .to receive(:codepoints_from_bracket_expression)
      .and_return([42])

    expect(variant.parse('foo').to_a).to eq [42]
  end

  it 'inverts the result if the argument is a negative bracket expression' do
    expect(CharacterSet::Parser)
      .to receive(:codepoints_from_bracket_expression)
      .and_return([42])

    double = instance_double(variant)
    allow(double).to receive(:inversion).and_return([23])
    expect(variant).to receive(:new).with([42]).and_return(double)
    expect(variant.parse('[^a]')).to eq [23]
  end
end

describe 'CharacterSet::parse' do
  it_behaves_like :character_set_parse, CharacterSet
end

describe 'CharacterSet::Pure::parse' do
  it_behaves_like :character_set_parse, CharacterSet::Pure
end

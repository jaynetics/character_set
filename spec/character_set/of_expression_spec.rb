require 'regexp_parser'

shared_examples :character_set_of_expression do |variant|
  it 'calls ExpressionConverter::convert, passing the expression and self' do
    expect(CharacterSet::ExpressionConverter)
      .to receive(:convert).with(:foo, variant)
    variant.of_expression(:foo)
  end
end

describe "CharacterSet::of_expression" do
  it_behaves_like :character_set_of_expression, CharacterSet
end

describe "CharacterSet::Pure::of_expression" do
  it_behaves_like :character_set_of_expression, CharacterSet::Pure
end

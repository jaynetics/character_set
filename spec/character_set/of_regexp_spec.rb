require 'regexp_parser'

shared_examples :character_set_of_regexp do |variant|
  it 'calls ::of_expression, passing the root expression' do
    allow(Regexp::Parser).to receive(:parse).and_return(:root)
    expect(variant).to receive(:of_expression).with(:root)
    variant.of_regexp(/foo/)
  end
end

describe "CharacterSet::of_regexp" do
  it_behaves_like :character_set_of_regexp, CharacterSet
end

describe "CharacterSet::Pure::of_regexp" do
  it_behaves_like :character_set_of_regexp, CharacterSet::Pure
end

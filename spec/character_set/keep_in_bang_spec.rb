# frozen_string_literal: true

shared_examples :character_set_keep_in_bang do |variant|
  it 'alters the given string, removing all Characters except those in self' do
    str = 'abc'.dup
    variant[97, 98, 99].keep_in!(str)
    expect(str).to eq 'abc'

    str = 'abz'.dup
    variant[97, 98, 99].keep_in!(str)
    expect(str).to eq 'ab'

    str = 'xy'.dup
    variant[97, 98, 99].keep_in!(str)
    expect(str).to eq ''

    str = ''.dup
    variant[1, 2, 3].keep_in!(str)
    expect(str).to eq ''

    str = 'abc'.dup
    variant[].keep_in!(str)
    expect(str).to eq ''
  end

  it 'returns nil iff the original string is unchanged' do
    expect(variant[97, 98, 99].keep_in!('abc'.dup)).to eq nil
    expect(variant[97, 98, 99].keep_in!('abz'.dup)).to eq 'ab'
  end

  it 'raises an ArgumentError if passed a non-String' do
    expect { variant[].keep_in!(false) }.to raise_error(ArgumentError)
    expect { variant[].keep_in!(nil) }.to raise_error(ArgumentError)
    expect { variant[].keep_in!(1) }.to raise_error(ArgumentError)
    expect { variant[].keep_in!(Object.new) }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError for broken strings' do
    expect { variant[].keep_in!("a\xC1\x80b".dup) }.to raise_error(ArgumentError)
  end

  it 'raises FrozenError if passed a frozen String' do
    expect { variant[97].keep_in!('abc'.freeze) }.to raise_error(FrozenError)
  end

  it 'isolates changes to a substring from its source buffer' do
    source = 'a😋ü' * 100
    substring = source[3, source.length - 6]
    variant['😋'].keep_in!(substring)
    expect(substring).to eq '😋' * 98
    expect(source).to eq 'a😋ü' * 100
  end

  it 'rejects frozen strings even when unchanged' do
    original = 'a😋ü'
    set = CharacterSet.of_string(original)
    expect { set.keep_in!(original.freeze) }.to raise_error(FrozenError)
  end
end

describe "CharacterSet#keep_in!" do
  it_behaves_like :character_set_keep_in_bang, CharacterSet

  it 'is memsafe' do
    set = CharacterSet[97, 98, 99]
    expect { set.keep_in!('abcd'.dup) }.to be_memsafe
  end
end

describe "CharacterSet::Pure#keep_in!" do
  it_behaves_like :character_set_keep_in_bang, CharacterSet::Pure
end

shared_examples :character_set_delete_in_bang do |variant|
  it 'alters the given string, removing all Characters in self' do
    str = 'abc'
    variant[97, 98, 99].delete_in!(str)
    expect(str).to eq ''

    str = 'abz'
    variant[97, 98, 99].delete_in!(str)
    expect(str).to eq 'z'

    str = 'xy'
    variant[97, 98, 99].delete_in!(str)
    expect(str).to eq 'xy'

    str = 'abz'
    variant[1, 2, 3].delete_in!(str)
    expect(str).to eq 'abz'

    str = ''
    variant[1, 2, 3].delete_in!(str)
    expect(str).to eq ''

    str = 'abc'
    variant[].delete_in!(str)
    expect(str).to eq 'abc'
  end

  it 'returns nil iff the original string is unchanged' do
    expect(variant[1, 2, 3].delete_in!('abz')).to eq nil
    expect(variant[97, 98, 99].delete_in!('abz')).to eq 'z'
  end

  it 'raises an ArgumentError if passed a non-String' do
    expect { variant[].delete_in!(false) }.to raise_error(ArgumentError)
    expect { variant[].delete_in!(nil) }.to raise_error(ArgumentError)
    expect { variant[].delete_in!(1) }.to raise_error(ArgumentError)
    expect { variant[].delete_in!(Object.new) }.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError for broken strings' do
    expect { variant[].delete_in!("a\xC1\x80b") }.to raise_error(ArgumentError)
  end

  it 'raises FrozenError if passed a frozen String',
     if: ruby_version_is_at_least('2.5') do
    expect { variant[97].delete_in!('abc'.freeze) }.to raise_error(FrozenError)
  end
end

describe "CharacterSet#delete_in!" do
  it_behaves_like :character_set_delete_in_bang, CharacterSet

  it 'is memsafe' do
    set = CharacterSet[97, 98, 99]
    expect { set.delete_in!('abcd') }.to be_memsafe
  end
end

describe "CharacterSet::Pure#delete_in!" do
  it_behaves_like :character_set_delete_in_bang, CharacterSet::Pure
end

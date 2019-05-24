# ruby-spec covers other cases

describe "CharacterSet::Pure#==" do
  it 'works with descendant classes' do
    descendant = Class.new(CharacterSet::Pure)
    expect(CharacterSet::Pure[97, 98, 99]).to eq descendant[97, 98, 99]
  end

  it 'works with CharacterSet' do
    expect(CharacterSet::Pure[97, 98, 99]).to eq CharacterSet[97, 98, 99]
  end
end

# ruby-spec covers other cases

shared_examples :character_set_section do |variant|
  it 'does not create shared mutable state' do
    set1 = variant[96, 97]
    set2 = set1.section(from: 96, upto: 96)
    expect(Leto.shared_mutable_state?(set1, set2)).to eq false
  end

  it 'includes both endpoints across a Unicode plane boundary' do
    set = variant[0xD800, 0xFFFF, 0x10000, 0x10FFFF]
    expect(set.section(from: 0xFFFF, upto: 0x10000).to_a).to eq [0xFFFF, 0x10000]
  end

  it 'preserves the subclass and isolates result mutations' do
    subclass = Class.new(variant)
    source = subclass[1, 2]
    result = source.section(from: 1, upto: 2)
    expect(result).to be_a subclass
    result.add(99)
    expect(source.to_a).to eq [1, 2]
  end
end

describe "CharacterSet#section" do
  it_behaves_like :character_set_section, CharacterSet
end

describe "CharacterSet::Pure#section" do
  it_behaves_like :character_set_section, CharacterSet::Pure
end

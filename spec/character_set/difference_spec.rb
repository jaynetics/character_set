# ruby-spec covers other cases

shared_examples :character_set_difference do |variant|
  %i[- difference].each do |method|
    it "does not create shared mutable state via ##{method}" do
      set1 = variant[96, 97]
      set2 = variant[97, 98]
      set3 = set1.send(method, set2)
      expect(Leto.shared_mutable_state?(set1, set2, set3)).to eq false
    end
  end

  it 'preserves the subclass and isolates result mutations' do
    subclass = Class.new(variant)
    source = subclass[1, 2]
    result = source - subclass[2]
    expect(result).to be_a subclass
    result.add(99)
    expect(source.to_a).to eq [1, 2]
  end
end

describe "CharacterSet#-" do
  it_behaves_like :character_set_difference, CharacterSet
end

describe "CharacterSet::Pure#-" do
  it_behaves_like :character_set_difference, CharacterSet::Pure
end

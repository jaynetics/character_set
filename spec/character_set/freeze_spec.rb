shared_examples :character_set_freeze do |variant|
  it 'marks the character set as frozen' do
    set = variant[97, 98, 99]
    expect { set.freeze }.to change { set.frozen? }.from(false).to(true)
  end

  it 'returns the character set itself' do
    set = variant[97, 98, 99]
    expect(set.freeze).to equal set
  end

  {
    'add' => ->(set) { set.add(1) },
    'add?' => ->(set) { set.add?(1) },
    'delete' => ->(set) { set.delete(2) },
    'delete?' => ->(set) { set.delete?(2) },
    'clear' => ->(set) { set.clear },
    'merge' => ->(set) { set.merge([]) },
    'subtract' => ->(set) { set.subtract([]) },
    'keep_if' => ->(set) { set.keep_if { true } },
    'delete_if' => ->(set) { set.delete_if { false } },
  }.each do |method, operation|
    it "prevents ##{method}, including no-ops" do
      set = variant[1].freeze
      expect { operation.call(set) }.to raise_error(FrozenError)
    end
  end
end

describe "CharacterSet#freeze" do
  it_behaves_like :character_set_freeze, CharacterSet
end

describe "CharacterSet::Pure#freeze" do
  it_behaves_like :character_set_freeze, CharacterSet::Pure
end

# This sequence checks interactions between methods against an independent model.
shared_examples :character_set_operation_sequence do |variant|
  it 'matches an independent set model through identical random mutations' do
    random = Random.new(20_261_026)
    set = variant.new
    model = []
    100.times do
      cp = random.rand(0x110000)
      case random.rand(4)
      when 0
        set.add(cp)
        model |= [cp]
      when 1
        set.delete(cp)
        model.delete(cp)
      when 2
        values = Array.new(8) { random.rand(0x110000) }
        other = CharacterSet.new(values)
        expect((set & other).to_a).to eq((model & values).sort)
        expect((set - other).to_a).to eq((model - values).sort)
        expect((set ^ other).to_a).to eq(((model | values) - (model & values)).sort)
        set.merge(other)
        model |= values
      when 3
        set = set.dup
      end
      expect(set.to_a).to eq model.sort
      expect(set.size).to eq model.size
    end
  end
end

describe "CharacterSet operation sequence" do
  it_behaves_like :character_set_operation_sequence, CharacterSet
end

describe "CharacterSet::Pure operation sequence" do
  it_behaves_like :character_set_operation_sequence, CharacterSet::Pure
end

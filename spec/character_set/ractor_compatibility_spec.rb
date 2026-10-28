# skip ractor test when evaluating coverage
# https://github.com/simplecov-ruby/simplecov/issues/1058
has_ractor = defined?(Ractor) && Ractor.method_defined?(:value)
evaluating_coverage = defined?(SimpleCov) && Coverage.running?
describe CharacterSet, if: has_ractor && !evaluating_coverage do
  it 'can be used with Ractor' do
    shared_instance = CharacterSet[97, 98, 99].freeze
    CharacterSet.const_set('RactorTestFrozen', shared_instance)

    ractor = Ractor.new { CharacterSet.const_get('RactorTestFrozen').object_id }
    expect(ractor.value).to eq shared_instance.object_id

    ractor = Ractor.new { CharacterSet.const_get('RactorTestFrozen').size }
    expect(ractor.value).to eq 3
  end
end

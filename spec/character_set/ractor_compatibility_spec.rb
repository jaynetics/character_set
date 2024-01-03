# skip ractor test when evaluating coverage
# https://github.com/simplecov-ruby/simplecov/issues/1058
describe CharacterSet, if: defined?(Ractor) && !defined?(SimpleCov) do
  it 'can be used with Ractor' do
    shared_instance = CharacterSet[97, 98, 99].freeze
    CharacterSet.const_set('RactorTestFrozen', shared_instance)

    ractor = Ractor.new { CharacterSet.const_get('RactorTestFrozen').object_id }
    expect(ractor.take).to eq shared_instance.object_id

    ractor = Ractor.new { CharacterSet.const_get('RactorTestFrozen').size }
    expect(ractor.take).to eq 3
  end
end


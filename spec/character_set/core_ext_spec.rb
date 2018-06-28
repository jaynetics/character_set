require 'character_set/core_ext'

RSpec.describe 'CharacterSet core extension' do
  describe 'String#character_set' do
    it 'returns the CharacterSet used by the String' do
      expect('abacababa'.character_set).to eq CharacterSet[97, 98, 99]
    end
  end

  describe 'String#covered_by?' do
    it 'return true iff the String is covered by the given CharacterSet' do
      expect('ab'.covered_by?(CharacterSet[97, 98, 99])).to be true
      expect('äb'.covered_by?(CharacterSet[97, 98, 99])).to be false
    end
  end

  describe 'String#covered_by?' do
    it 'return true iff the String is uses the given CharacterSet' do
      expect('ab'.uses?(CharacterSet[97, 98, 99])).to be true
      expect('xy'.uses?(CharacterSet[97, 98, 99])).to be false
    end
  end
end

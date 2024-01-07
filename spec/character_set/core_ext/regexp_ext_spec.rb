require 'character_set/core_ext/regexp_ext'

describe 'CharacterSet Regexp core extension' do
  describe 'Regexp#character_set' do
    it 'calls CharacterSet::of_regexp, passing self' do
      regexp = /[a-z]/
      expect(CharacterSet).to receive(:of_regexp).with(regexp)
      regexp.character_set
    end
  end

  describe 'Regexp#covered_by_character_set?' do
    it 'returns true iff the regexp uses only the given character set' do
      regexp = /[a-z]/
      expect(regexp.covered_by_character_set?(CharacterSet.new('a'..'z'))).to be true
      expect(regexp.covered_by_character_set?(CharacterSet.new('b'..'z'))).to be false
      expect(regexp.covered_by_character_set?(CharacterSet.new('a'..'y'))).to be false
      expect(regexp.covered_by_character_set?(CharacterSet.new(0..0xFFFF))).to be true
    end
  end

  describe 'Regexp#uses_character_set?' do
    it 'returns true iff the regexp uses the given character set' do
      regexp = /[a-z]/
      expect(regexp.uses_character_set?(CharacterSet['a'])).to be true
      expect(regexp.uses_character_set?(CharacterSet['µ'])).to be false
    end
  end
end

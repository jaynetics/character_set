require 'character_set/core_ext/regexp_ext'

RSpec.describe 'CharacterSet Regexp core extension' do
  describe 'Regexp#character_set' do
    it 'calls CharacterSet::of_regexp, passing self' do
      regexp = /foo/
      expect(CharacterSet).to receive(:of_regexp).with(regexp)
      regexp.character_set
    end
  end
end

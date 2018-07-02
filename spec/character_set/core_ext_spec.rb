require 'character_set/core_ext'

RSpec.describe 'CharacterSet core extension' do
  describe 'String#character_set' do
    it 'calls CharacterSet::of, passing self' do
      expect(CharacterSet).to receive(:of).with('foo')
      'foo'.character_set
    end
  end

  describe 'String#covered_by_character_set?' do
    it 'calls CharacterSet#cover?, passing self' do
      set = CharacterSet.new
      expect(set).to receive(:cover?).with('foo')
      'foo'.covered_by_character_set?(set)
    end
  end

  describe 'String#uses_character_set?' do
    it 'calls CharacterSet#used_by?, passing self' do
      set = CharacterSet.new
      expect(set).to receive(:used_by?).with('foo')
      'foo'.uses_character_set?(set)
    end
  end

  describe 'String#delete_character_set' do
    it 'calls CharacterSet#delete_in, passing self' do
      set = CharacterSet.new
      expect(set).to receive(:delete_in).with('foo')
      'foo'.delete_character_set(set)
    end
  end

  describe 'String#delete_character_set!' do
    it 'calls CharacterSet#delete_in!, passing self' do
      set = CharacterSet.new
      expect(set).to receive(:delete_in!).with('foo')
      'foo'.delete_character_set!(set)
    end
  end

  describe 'String#keep_character_set' do
    it 'calls CharacterSet#keep_in, passing self' do
      set = CharacterSet.new
      expect(set).to receive(:keep_in).with('foo')
      'foo'.keep_character_set(set)
    end
  end

  describe 'String#keep_character_set!' do
    it 'calls CharacterSet#keep_in!, passing self' do
      set = CharacterSet.new
      expect(set).to receive(:keep_in!).with('foo')
      'foo'.keep_character_set!(set)
    end
  end
end

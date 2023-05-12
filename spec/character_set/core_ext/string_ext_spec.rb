require 'character_set/core_ext/string_ext'

describe 'CharacterSet String core extension' do
  describe 'String#character_set' do
    it 'calls CharacterSet::of_string, passing self' do
      expect(CharacterSet).to receive(:of_string).with('foo')
      'foo'.character_set
    end
  end

  shared_examples :string_ext_method do |string_method, set_method|
    it "calls CharacterSet##{set_method} with self if given a CharacterSet" do
      set = CharacterSet.new
      expect(set).to receive(set_method).with('foo')
      'foo'.send(string_method, set)
    end

    it 'uses the corresponding predefined set if given a Symbol' do
      string = 'foo'
      spy_set = instance_double(CharacterSet)
      expect(CharacterSet).to receive(:my_spy_set).and_return(spy_set)
      expect(spy_set).to receive(set_method).with(string)
      string.send(string_method, :my_spy_set)
    end

    it 'raises if there is no predefined set matching the Symbol' do
      expect { 'foo'.send(string_method, :fancy_set) }
        .to raise_error(/undefined method .*fancy_set.* for .*CharacterSet/)
    end
  end

  describe 'String#count_by_character_set' do
    it_behaves_like :string_ext_method, :count_by_character_set, :count_in
  end

  describe 'String#covered_by_character_set?' do
    it_behaves_like :string_ext_method, :covered_by_character_set?, :cover?
  end

  describe 'String#delete_character_set' do
    it_behaves_like :string_ext_method, :delete_character_set, :delete_in
  end

  describe 'String#delete_character_set!' do
    it_behaves_like :string_ext_method, :delete_character_set!, :delete_in!
  end

  describe 'String#keep_character_set' do
    it_behaves_like :string_ext_method, :keep_character_set, :keep_in
  end

  describe 'String#keep_character_set!' do
    it_behaves_like :string_ext_method, :keep_character_set!, :keep_in!
  end

  describe 'String#scan_by_character_set' do
    it_behaves_like :string_ext_method, :scan_by_character_set, :scan
  end

  describe 'String#uses_character_set?' do
    it_behaves_like :string_ext_method, :uses_character_set?, :used_by?
  end
end

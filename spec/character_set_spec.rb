describe CharacterSet do
  it 'has a version number' do
    expect(CharacterSet::VERSION).not_to be nil
  end

  if RUBY_PLATFORM[/java/i]
    it 'uses the RubyFallback in non-C rubies' do
      expect(CharacterSet.ancestors).to include(CharacterSet::RubyFallback)
    end
  else
    it 'does not use the RubyFallback in C rubies' do
      expect(CharacterSet.ancestors).not_to include(CharacterSet::RubyFallback)
    end
  end
end

describe CharacterSet do
  it 'has a version number' do
    expect(CharacterSet::VERSION).not_to be nil
  end

  it 'uses the RubyFallback in non-C rubies' do
    if RUBY_PLATFORM[/java/i]
      expect(CharacterSet.ancestors).to include(CharacterSet::RubyFallback)
    else
      expect(CharacterSet.ancestors).not_to include(CharacterSet::RubyFallback)
    end
  end
end

# frozen_string_literal: false

describe CharacterSet do
  it 'has a version number' do
    expect(CharacterSet::VERSION).not_to be nil
  end

  case RUBY_ENGINE
  when 'ruby'
    it 'does not use the RubyFallback in C rubies' do
      expect(CharacterSet.ancestors).not_to include(CharacterSet::RubyFallback)
    end
  when 'jruby'
    it 'uses the Java backend on JRuby' do
      expect(CharacterSet.new.to_java.java_class.name)
        .to eq('org.jaynetics.characterset.RubyCharacterSet')
    end
  end
end

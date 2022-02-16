shared_examples :character_set_require_optional_dependency do |variant|
  it 'returns true if the dependency is available' do
    expect(variant.require_optional_dependency('csv', :foo)).to be true
  end

  it 'returns true for already-loaded dependencies' do
    variant.require_optional_dependency('csv', :foo)
    expect(variant.require_optional_dependency('csv', :foo)).to be true
  end

  it 'raises LoadError if the dependency is not available' do
    expect { variant.require_optional_dependency('inexistent_gem', :foo) }
      .to raise_error(LoadError)
  end

  it 'mentions the missing dependency and entry point in the error message',
     if: Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.2.0') do
    allow(variant).to receive(:new) do
      variant.require_optional_dependency('inexistent_gem', :foo)
    end
    foo = ->{ variant[] }

    skip 'matcher is currently broken on jruby-head' if RUBY_PLATFORM[/java/i]
    expect { foo.call }.to raise_error(/inexistent_gem.*`foo'/)
  end
end

describe "CharacterSet::require_optional_dependency" do
  it_behaves_like :character_set_require_optional_dependency, CharacterSet
end

describe "CharacterSet::Pure::require_optional_dependency" do
  it_behaves_like :character_set_require_optional_dependency, CharacterSet::Pure
end

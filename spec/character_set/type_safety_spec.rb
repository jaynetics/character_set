# the core behavior of the methods below is tested by ruby-spec.
# this file just includes additional, paranoid type-safety tests,
# as trying to handle codepoints beyond the bounds would lead to a segfault.

item_methods = %w[add add? delete delete? include? member?]

[CharacterSet, CharacterSet::Pure].product(item_methods).each do |variant, method|
  describe "#{variant}##{method}" do
    it 'raises ArgumentError for inapplicable values' do
      expect { variant[].send(method, -1) }.to raise_error(ArgumentError)
      expect { variant[].send(method, -(10**200)) }.to raise_error(ArgumentError)
      expect { variant[].send(method, 10**200) }.to raise_error(ArgumentError)
      expect { variant[].send(method, nil) }.to raise_error(ArgumentError)
      expect { variant[].send(method, :foo) }.to raise_error(ArgumentError)
      expect { variant[].send(method, []) }.to raise_error(ArgumentError)
      expect { variant[].send(method, Object.new) }.to raise_error(ArgumentError)
    end
  end
end

mass_methods = %w[merge subtract + - & ^ > >= < <= <=> intersect? disjoint?]

[CharacterSet, CharacterSet::Pure].product(mass_methods).each do |variant, method|
  describe "#{variant}##{method}" do
    it 'raises ArgumentError or TypeError for inapplicable values' do
      check = ->(err){ expect([ArgumentError, TypeError]).to include err.class }
      expect { variant[].send(method, [0, -1]) }.to raise_error(&check)
      expect { variant[].send(method, [0, -(10**200)]) }.to raise_error(&check)
      expect { variant[].send(method, [0, 10**200]) }.to raise_error(&check)
      expect { variant[].send(method, [0, nil]) }.to raise_error(&check)
      expect { variant[].send(method, [0, :foo]) }.to raise_error(&check)
      expect { variant[].send(method, [0, []]) }.to raise_error(&check)
      expect { variant[].send(method, [0, Object.new]) }.to raise_error(&check)
    end
  end
end

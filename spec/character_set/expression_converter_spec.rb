require 'regexp_parser'

RSpec.describe CharacterSet::ExpressionConverter do
  describe '::convert' do
    def result(arg, test_root = false)
      exp = Regexp::Parser.parse(arg)
      CharacterSet::ExpressionConverter.convert(test_root ? exp : exp[0])
    end

    it 'parses root expressions recursively' do
      expect(result(/[abc]/, true)).to eq CharacterSet['a', 'b', 'c']
    end

    it 'raises when passed a root containing != 1 expression' do
      expect { result(/[a][b]/, true) }.to raise_error(described_class::Error)
    end

    it 'parses literals of length 1' do
      expect(result(/a/)).to eq CharacterSet['a']
    end

    it 'raises when passed a literal with length != 1 outside a set' do
      expect { result(/abc/) }.to raise_error(described_class::Error)
    end

    it 'supports ranges' do
      expect(result(/[a-c]/)).to eq CharacterSet['a', 'b', 'c']
    end

    it 'supports negated sets' do
      expect(result(/[^\x00\u0004-\u{10FFFF}]/)).to eq CharacterSet[1, 2, 3]
    end

    it 'supports intersections' do
      expect(result(/[a-f&&c-z]/)).to eq CharacterSet['c', 'd', 'e', 'f']
    end

    it 'supports properties' do
      expect(result(/\p{ascii}/)).to eq CharacterSet.from_ranges(0x00..0x7F)
    end

    it 'supports posix classes' do
      expect(result(/[[:ascii:]]/)).to eq CharacterSet.from_ranges(0x00..0x7F)
    end

    it 'supports capturing, passive, named, atomic and option groups' do
      expect(result(/((?:(?<foo>(?>(?m:[a-c])))))/)).to eq CharacterSet['a', 'b', 'c']
    end

    it 'supports alternations' do
      expect(result(/(a|[b-d])/)).to eq CharacterSet['a', 'b', 'c', 'd']
    end

    it 'raises for unsupported expressions' do
      expect { result(/\b/) }.to raise_error(described_class::Error)
    end

    it 'raises for non-expressions' do
      expect do
        CharacterSet::ExpressionConverter.convert(:foo)
      end.to raise_error(described_class::Error)
    end
  end
end

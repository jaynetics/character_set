require 'regexp_parser'

describe CharacterSet::ExpressionConverter do
  describe '::convert' do
    def result(arg, to: CharacterSet)
      root = Regexp::Parser.parse(arg)
      CharacterSet::ExpressionConverter.convert(root, to)
    end

    it 'converts into the given Set class' do
      expect(result(/a/, to: CharacterSet)).to       eq CharacterSet['a']
      expect(result(/a/, to: CharacterSet::Pure)).to eq CharacterSet::Pure['a']
      expect(result(/a/, to: sorted_set_class)).to   eq sorted_set_class['a']
    end

    it 'parses root expressions recursively' do
      expect(result(/[abc]/)).to eq CharacterSet['a', 'b', 'c']
    end

    it 'supports multiple subexpressions' do
      expect(result(/[a][b]/)).to eq CharacterSet['a', 'b']
    end

    it 'parses literals' do
      expect(result(/a/)).to eq CharacterSet['a']
      expect(result(/abc/)).to eq CharacterSet['a', 'b', 'c']
    end

    it 'supports the match-all dot' do
      expect(result(/./)).to eq CharacterSet.unicode
    end

    it 'supports types' do
      expect(result(/\d/)).to eq CharacterSet.of('0123456789')
      expect(result(/\h/)).to eq CharacterSet.from_ranges(48..57, 65..70, 97..102)
      expect(result(/\w/)).to eq CharacterSet.from_ranges(48..57, 65..90, 95..95, 97..122)
      expect(result(/\s/)).to eq CharacterSet.from_ranges(9..13, 32..32)
      expect(result(/\R/)).to eq CharacterSet.from_ranges(10..13)
    end

    it 'supports negative types' do
      expect(result(/\D/)).to eq CharacterSet.of('0123456789').inversion
    end

    it 'supports types with the full unicode range' do
      expect(result(/(?u:\s)/)).to be > CharacterSet.from_ranges(9..13, 32..32)
      expect(result(/(?u:\R)/)).to be > CharacterSet.from_ranges(10..13)
    end

    it 'supports ranges' do
      expect(result(/[a-c]/)).to eq CharacterSet['a', 'b', 'c']
    end

    it 'supports negated sets' do
      expect(result(/[^\x00\u0004-\u{10FFFF}]/)).to eq CharacterSet[1, 2, 3]
    end

    it 'supports empty sets (though invalid as Regexp literal)' do
      expect(result('[]')).to eq CharacterSet[]
    end

    it 'supports intersections' do
      expect(result(/[a-f&&c-z]/)).to eq CharacterSet['c', 'd', 'e', 'f']
      # Intersections can lack one or both sides. In these cases they
      # match nothing, e.g. `/[a&&]/` matches neither `a` nor `&`.
      expect(result('[a&&]')).to eq CharacterSet[]
      expect(result('[&&a]')).to eq CharacterSet[]
      expect(result('[&&]')).to eq CharacterSet[]
    end

    it 'supports properties' do
      expect(result(/\p{ascii}/)).to eq CharacterSet.from_ranges(0x00..0x7F)
    end

    it 'supports posix classes' do
      expect(result(/[[:ascii:]]/)).to eq CharacterSet.from_ranges(0x00..0x7F)
    end

    it 'supports posix classes with ascii encoding' do
      expect(result(/[[:digit:]]/)).to be > CharacterSet.of('0123456789')
      expect(result(/(?a:[[:digit:]])/)).to eq CharacterSet.of('0123456789')
    end

    it 'supports capturing, passive, named, atomic and option groups' do
      expect(result(/(?:(?:(?<foo>(?>(?m:[a-c])))))/)).to eq CharacterSet['a', 'b', 'c']
    end

    it 'supports empty groups' do
      expect(result(/()/)).to eq CharacterSet[]
    end

    it 'supports groups containing more than one expression' do
      expect(result(/([a][b])/)).to eq CharacterSet['a', 'b']
    end

    it 'supports alternations' do
      expect(result(/(a|[b-d])/)).to eq CharacterSet['a', 'b', 'c', 'd']
    end

    it 'supports alternations with empty branches' do
      expect(result(/(|[b-d])/)).to eq CharacterSet['b', 'c', 'd']
    end

    it 'supports alternations branches containing more than one expression' do
      expect(result(/(a|b(c|d))/)).to eq CharacterSet['a', 'b', 'c', 'd']
    end

    it 'supports global and local case insensitivity' do
      expect(result(/a/i)).to eq CharacterSet['a', 'A']
      expect(result(/\x61/i)).to eq CharacterSet['a', 'A']
      expect(result(/\u{61}/i)).to eq CharacterSet['a', 'A']
      expect(result(/a(?i)b/)).to eq CharacterSet['a', 'b', 'B']
      expect(result(/a(?i:b)c/)).to eq CharacterSet['a', 'b', 'B', 'c']
    end

    it 'ignores zero-length and repeat expressions' do
      expect(result(/\b/)).to eq CharacterSet[]
      expect(result(/a+/)).to eq CharacterSet['a']
      expect(result(/(a)\1/)).to eq CharacterSet['a']
    end

    it 'raises for unknown expressions' do
      klass = Class.new(Regexp::Expression::Base) do
        def initialize; end # rubocop:disable Lint/MissingSuper
      end
      allow(Regexp::Parser).to receive(:parse).and_return klass.new
      expect { result(//) }.to raise_error(described_class::Error)
    end

    it 'raises for non-expressions' do
      expect do
        CharacterSet::ExpressionConverter.convert(:foo)
      end.to raise_error(described_class::Error)
    end
  end
end

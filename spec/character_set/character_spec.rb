describe CharacterSet::Character do
  Character = described_class

  describe '#initialize' do
    it 'works with Integers' do
      expect(Character.new(97).codepoint).to eq 97
    end

    it 'works with Strings' do
      expect(Character.new('a').codepoint).to eq 97
    end

    it 'raises ArgumentError if passed anything else' do
      expect { Character.new(:foo) }.to raise_error(ArgumentError)
      expect { Character.new(nil) }.to raise_error(ArgumentError)
    end
  end

  describe '#to_s' do
    it 'returns the character literal' do
      expect(Character.new('a').to_s).to eq 'a'
      expect(Character.new('😋').to_s).to eq '😋'
    end
  end

  describe '#hex' do
    it 'returns the hex value of the codepoint' do
      expect(Character.new('a').hex).to eq '61'
      expect(Character.new('😋').hex).to eq '1F60B'
    end
  end

  describe '#escape' do
    context 'if the codepoint is printable' do
      it 'it returns a literal if escape_all is not set' do
        expect(Character.new('a').escape).to eq 'a'
      end

      it 'it escapes it anyway if escape_all is set' do
        expect(Character.new('a').escape(escape_all: true)).to eq '\x61'
      end
    end

    context 'if the codepoint is not generally printable' do
      it 'it escapes it by default' do
        expect(Character.new('-' ).escape).to eq '\x2D'
        expect(Character.new('/' ).escape).to eq '\x2F'
        expect(Character.new('[' ).escape).to eq '\x5B'
        expect(Character.new('\\').escape).to eq '\x5C'
        expect(Character.new(']' ).escape).to eq '\x5D'
        expect(Character.new('^' ).escape).to eq '\x5E'
        expect(Character.new('😋').escape).to eq '\u{1F60B}'
      end

      it 'it returns a literal anyway with format: raw/literal' do
        expect(Character.new('😋').escape(format: :raw)).to eq '😋'
        expect(Character.new('😋').escape(format: :literal)).to eq '😋'
      end
    end

    context 'without format or format: default/es6/esnext/rb/ruby' do
      it 'returns \u escapes filled to 4 places for bmp chars' do
        [nil, ''] + %w[default es6 esnext rb ruby].each do |f|
          expect(Character.new(600).escape(format: f)).to eq '\u0258'
        end
      end

      it 'returns \u{...} escapes for astral chars' do
        [nil, ''] + %w[default es6 esnext rb ruby].each do |f|
          expect(Character.new('😋').escape(format: f)).to eq '\u{1F60B}'
        end
      end
    end

    context 'with format: java/javascript/js' do
      it 'returns \u escapes filled to 4 places for bmp chars' do
        %w[java javascript js].each do |f|
          expect(Character.new(600).escape(format: f)).to eq '\u0258'
        end
      end

      it 'raises for astral chars' do
        %w[java javascript js].each do |f|
          expect { Character.new('😋').escape(format: f) }
            .to raise_error(RuntimeError,
                            "#{f} does not support escaping astral value 1F60B")
        end
      end
    end

    context 'with format: capitalizableu/c#/d/python' do
      it 'returns \u escapes filled to 4 places for bmp chars' do
        %w[capitalizableu c# d python].each do |f|
          expect(Character.new(600).escape(format: f)).to eq '\u0258'
        end
      end

      it 'returns \U escapes filled to 8 places for astral chars' do
        %w[capitalizableu c# d python].each do |f|
          expect(Character.new('😋').escape(format: f)).to eq '\U0001F60B'
        end
      end
    end

    context 'with format: u+/uplus' do
      it 'returns U+ escapes filled to at least 4 places' do
        %w[u+ uplus].each do |f|
          expect(Character.new(600).escape(format: f)).to eq 'U+0258'
          expect(Character.new('😋').escape(format: f)).to eq 'U+1F60B'
        end
      end
    end

    context 'with an unknown format' do
      it 'raises an ArgumentError' do
        expect { Character.new(600).escape(format: :foo) }
          .to raise_error(ArgumentError, 'unsupported format: :foo')
      end
    end
  end

  describe '#plane' do
    it 'returns the unicode plane number of the character' do
      expect(Character.new(0).plane).to eq 0
      expect(Character.new(600).plane).to eq 0
      expect(Character.new(128_523).plane).to eq 1
      expect(Character.new(131_071).plane).to eq 1
      expect(Character.new(131_072).plane).to eq 2
      expect(Character.new(0x10FFFF).plane).to eq 16
    end
  end
end

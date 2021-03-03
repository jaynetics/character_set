describe CharacterSet::Writer do
  let(:writer) { described_class }

  describe '::write' do
    it 'turns an Array of codepoint Ranges into a bracket expression String' do
      expect(writer.write([])).to eq ''
      expect(writer.write([97..97])).to eq 'a'
      expect(writer.write([97..99])).to eq 'a-c'
      expect(writer.write([97..99, 101..101])).to eq 'a-ce'
    end

    it 'does not abbreviate (build ranges) iff abbreviate: is false' do
      expect(writer.write([97..99], abbreviate: false)).to eq 'abc'
    end

    it 'adds surrounding brackets iff in_brackets: is true' do
      expect(writer.write([97..99], in_brackets: true)).to eq '[a-c]'
    end

    it 'passes escape_all: to Character#escape' do
      expect(writer.write([97..97], escape_all: true)).to eq '\x61'
    end

    it 'passes format: to Character#escape' do
      expect(writer.write([0x1F60B..0x1F60B], format: 'u+')).to eq 'U+1F60B'
    end

    it 'passes a given block to Character#escape' do
      expect(writer.write([250..255], &:hex)).to eq 'FA-FF'
    end
  end

  describe '::write_surrogate_ranges' do
    def result(bmp_ranges, astral_ranges)
      writer.write_surrogate_ranges(bmp_ranges, astral_ranges)
    end

    it 'turns bmp and astral ranges into an alternation expression' do
      expect(result([97..99], [0x1A60B..0x1F60F]))
        .to eq '(?:[a-c]|\uD829[\uDE0B-\uDFFF]|[\uD82A-\uD83C][\uDC00-\uDFFF]|\uD83D[\uDC00-\uDE0F])'
    end

    it 'turns bmp and short astral ranges into an alternation expression' do
      expect(result([97..99], [0x1F60B..0x1F60B]))
        .to eq '(?:[a-c]|\uD83D\uDE0B)'
    end

    it 'works with multiple astral ranges' do
      expect(result([], [0x1F60B..0x1F60C, 0x1F60E..0x1F60F]))
        .to eq '(?:\uD83D[\uDE0B\uDE0C\uDE0E\uDE0F])'
    end

    it 'works with large astral ranges (spanning multiple low surrogates)' do
      expect(result([], [0x10000..0x10FFFF]))
        .to eq '(?:[\uD800-\uDBFF][\uDC00-\uDFFF])'
    end

    it 'does not use a bracket expression for single high surrogates' do
      expect(result([97..99], [0x1F60B..0x1F60F]))
        .to eq '(?:[a-c]|\uD83D[\uDE0B-\uDE0F])'
    end

    it 'returns just a bracket expression String if there are no astral bits' do
      expect(result([97..99], []))
        .to eq '[a-c]'
    end

    it 'returns an empty expression if there are neither bmp nor astral bits' do
      expect(result([], []))
        .to eq '(?:)'
    end

    it 'uses the js escape format for not universally printable chars' do
      expect(result([600..600], []))
        .to eq '[\u0258]'
    end

    it 'doesnt include an empty bracket expression if there are no bmp bits' do
      expect(result([], [0x1F60B..0x1F60C]))
        .to eq '(?:\uD83D[\uDE0B\uDE0C])'
    end
  end

  describe '::write_surrogate_alternation' do
    def result(bmp_ranges, astral_ranges)
      writer.write_surrogate_alternation(bmp_ranges, astral_ranges)
    end

    it 'turns bmp and astral ranges into an alternation expression' do
      expect(result([97..99], [0x1F60B..0x1F60C]))
        .to eq '(?:[a-c]|\uD83D\uDE0B|\uD83D\uDE0C)'
    end

    it 'returns just a bracket expression String if there are no astral bits' do
      expect(result([97..99], []))
        .to eq '[a-c]'
    end

    it 'returns an empty expression if there are neither bmp nor astral bits' do
      expect(result([], []))
        .to eq '(?:)'
    end

    it 'uses the js escape format for not universally printable chars' do
      expect(result([600..600], []))
        .to eq '[\u0258]'
    end

    it 'doesnt include an empty bracket expression if there are no bmp bits' do
      expect(result([], [0x1F60B..0x1F60C]))
        .to eq '(?:\uD83D\uDE0B|\uD83D\uDE0C)'
    end
  end
end

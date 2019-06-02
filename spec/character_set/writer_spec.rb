describe CharacterSet::Writer do
  Writer = described_class

  describe '::write' do
    it 'turns an Array of codepoint Ranges into a bracket expression String' do
      expect(Writer.write([])).to eq ''
      expect(Writer.write([97..97])).to eq 'a'
      expect(Writer.write([97..99])).to eq 'a-c'
      expect(Writer.write([97..99, 101..101])).to eq 'a-ce'
    end

    it 'does not abbreviate (build ranges) iff abbreviate: is false' do
      expect(Writer.write([97..99], abbreviate: false)).to eq 'abc'
    end

    it 'adds surrounding brackets iff in_brackets: is true' do
      expect(Writer.write([97..99], in_brackets: true)).to eq '[a-c]'
    end

    it 'passes escape_all: to Character#escape' do
      expect(Writer.write([97..97], escape_all: true)).to eq '\x61'
    end

    it 'passes format: to Character#escape' do
      expect(Writer.write([0x1F60B..0x1F60B], format: 'u+')).to eq 'U+1F60B'
    end

    it 'passes a given block to Character#escape' do
      expect(Writer.write([250..255], &:hex)).to eq 'FA-FF'
    end
  end

  describe '::write_surrogate_ranges' do
    def result(bmp_ranges, astral_codepoints)
      Writer.write_surrogate_ranges(bmp_ranges, astral_codepoints)
    end

    it 'turns bmp and astral ranges into an alternation expression' do
      expect(result([97..99], [0x1A60B..0x1F60F]))
        .to eq '(?:[\\ud829-\\ud83d][\\ude0b-\\ude0f]|[a-c])'
    end

    it 'turns bmp and short astral ranges into an alternation expression' do
      expect(result([97..99], [0x1F60B..0x1F60C]))
        .to eq '(?:\ud83d\ude0b|\ud83d\ude0c|[a-c])'
    end

    it 'does not use a range for single high surrogate' do
      expect(result([97..99], [0x1F60B..0x1F60F]))
        .to eq '(?:\\ud83d[\\ude0b-\\ude0f]|[a-c])'
    end

    it 'returns just a bracket expression String if there are no astral bits' do
      expect(result([97..99], []))
        .to eq '[a-c]'
    end

    it 'uses the js escape format for not universally printable chars' do
      expect(result([600..600], []))
        .to eq '[\u0258]'
    end

    it 'doesnt include an empty bracket expression if there are no bmp bits' do
      expect(result([], [0x1F60B..0x1F60F]))
        .to eq '(?:\\ud83d[\\ude0b-\\ude0f])'
    end
  end

  describe '::write_surrogate_alternation' do
    def result(bmp_ranges, astral_codepoints)
      Writer.write_surrogate_alternation(bmp_ranges, astral_codepoints)
    end

    it 'turns bmp and astral ranges into an alternation expression' do
      expect(result([97..99], [0x1F60B..0x1F60C]))
        .to eq '(?:[a-c]|\ud83d\ude0b|\ud83d\ude0c)'
    end

    it 'returns just a bracket expression String if there are no astral bits' do
      expect(result([97..99], []))
        .to eq '[a-c]'
    end

    it 'uses the js escape format for not universally printable chars' do
      expect(result([600..600], []))
        .to eq '[\u0258]'
    end

    it 'doesnt include an empty bracket expression if there are no bmp bits' do
      expect(result([], [0x1F60B..0x1F60C]))
        .to eq '(?:\ud83d\ude0b|\ud83d\ude0c)'
    end
  end
end

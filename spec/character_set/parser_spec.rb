describe CharacterSet::Parser do
  describe '::codepoints_from_enumerable' do
    def result(arg)
      CharacterSet::Parser.codepoints_from_enumerable(arg).to_a
    end

    it 'takes an Array of Integers' do
      expect(result([97, 98, 99])).to eq [97, 98, 99]
    end

    it 'takes an Array of Strings' do
      expect(result(['a', 'b', 'c'])).to eq [97, 98, 99]
    end

    it 'takes a Range of Integers' do
      expect(result(97..99)).to eq [97, 98, 99]
    end

    it 'takes a Range of Strings' do
      expect(result('a'..'c')).to eq [97, 98, 99]
    end

    it 'takes a Set of Integers' do
      expect(result(sorted_set_class[97, 98, 99])).to eq [97, 98, 99]
    end

    it 'takes a Set of Strings' do
      expect(result(sorted_set_class['a', 'b', 'c'])).to eq [97, 98, 99]
    end

    it 'takes a CharacterSet' do
      set = CharacterSet[97, 98, 99]
      expect(result(set)).to eq [97, 98, 99]
    end

    it 'works with Strings in non-utf8-compatible encodings' do
      expect(result(['a', 'ü'.encode('EUC-JP')])).to eq [97, 0xFC]
    end

    it 'raises for invalid contents' do
      expect { result([Object.new]) }.to raise_error(ArgumentError)
    end
  end

  describe '::codepoints_from_bracket_expression' do
    def result(arg)
      CharacterSet::Parser.codepoints_from_bracket_expression(arg)
    end

    it 'parses a simple bracket expression and returns contained codepoints' do
      expect(result('[abc]')).to eq [97, 98, 99]
    end

    it 'can handle a negative bracket expression' do
      expect(result('[^abc]')).to eq [97, 98, 99]
    end

    it 'can handle a bracket expression without brackets' do
      expect(result('abc')).to eq [97, 98, 99]
    end

    it 'can handle ranges' do
      expect(result('[a-c]')).to eq [97, 98, 99]
    end

    it 'can handle \\uHHHH escapes' do
      expect(result('[ab\\u0063]')).to eq [97, 98, 99]
    end

    it 'can handle \\UHHHHHHHH escapes' do
      expect(result('[ab\\U00000063]')).to eq [97, 98, 99]
    end

    it 'can handle U+HH escapes' do
      expect(result('[abU+63]')).to eq [97, 98, 99]
    end

    it 'can handle \\u{HH} escapes' do
      expect(result('[ab\\u{63}]')).to eq [97, 98, 99]
    end

    it 'can handle \\xHH escapes' do
      expect(result('[ab\\x63]')).to eq [97, 98, 99]
    end

    it 'can handle mixed escapes and ranges' do
      expect(result('[U+61-\\u{63}]')).to eq [97, 98, 99]
    end
  end
end

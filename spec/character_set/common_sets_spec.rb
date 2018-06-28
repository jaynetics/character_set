RSpec.describe CharacterSet::CommonSets do
  describe '::ascii' do
    it 'includes all ASCII codepoints' do
      expect(CharacterSet.ascii.size).to eq 0x80
      expect(CharacterSet.ascii).to include 'a'
      expect(CharacterSet.ascii).to include '1'
      # `not_to include` is extremely slow for some reason?!
      expect(CharacterSet.ascii.include?('ü')).to be false
    end

    it 'is frozen' do
      expect(CharacterSet.ascii).to be_frozen
    end
  end

  describe '::emoji' do
    it 'includes all emoji codepoints' do
      expect(CharacterSet.emoji.include?('a')).to be false
      expect(CharacterSet.emoji).to include '😋'
    end

    it 'is frozen' do
      expect(CharacterSet.emoji).to be_frozen
    end
  end

  describe '::newline' do
    it 'includes all newline codepoints' do
      expect(CharacterSet.newline).to include "\n"
      expect(CharacterSet.newline).to include "\r"
    end

    it 'is frozen' do
      expect(CharacterSet.newline).to be_frozen
    end
  end

  describe '::non_ascii' do
    it 'includes all valid, non-ascii codepoints' do
      expect(CharacterSet.non_ascii.size).to eq 0x110000 - 0x800 - 0x80
      expect(CharacterSet.non_ascii.include?('a')).to be false
      expect(CharacterSet.non_ascii.include?('1')).to be false
      expect(CharacterSet.non_ascii).to include 'ü'
      expect(CharacterSet.non_ascii).to include '😋'
    end

    it 'is frozen' do
      expect(CharacterSet.non_ascii).to be_frozen
    end
  end

  describe '::unicode' do
    it 'includes all valid unicode codepoints' do
      expect(CharacterSet.unicode.size).to eq 0x110000 - 0x800
      expect(CharacterSet.unicode).to include 'a'
      expect(CharacterSet.unicode).to include '😋'
    end

    it 'is frozen' do
      expect(CharacterSet.unicode).to be_frozen
    end
  end

  describe '::whitespace' do
    it 'includes all whitespace codepoints' do
      expect(CharacterSet.whitespace).to include ' '
      expect(CharacterSet.whitespace).to include "\n"
    end

    it 'is frozen' do
      expect(CharacterSet.whitespace).to be_frozen
    end
  end
end

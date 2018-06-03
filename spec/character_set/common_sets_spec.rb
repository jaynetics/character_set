RSpec.describe CharacterSet::CommonSets do
  describe '::ascii' do
    it 'includes all ASCII codepoints' do
      set = CharacterSet.ascii
      expect(set.size).to eq 0x80
      expect(set).to include 'a'
      expect(set).to include '1'
      expect(set).not_to include 'ü'
    end
  end

  describe '::newlines' do
    it 'includes various newline codepoints' do
      set = CharacterSet.newlines
      expect(set).to include "\n"
      expect(set).to include "\r"
    end
  end

  describe '::unicode' do
    it 'includes all valid unicode codepoints' do
      set = CharacterSet.unicode
      expect(set.size).to eq 0x110000 - 0x800
      expect(set).to include 'a'
      expect(set).to include '😋'
    end
  end
end

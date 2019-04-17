describe CharacterSet::PredefinedSets do
  shared_examples :predefined_character_set do |name|
    it 'is frozen' do
      expect(CharacterSet.send(name)).to be_frozen
    end

    it 'has an inversion' do
      orig = CharacterSet.send(name)
      expect(CharacterSet.send("non_#{name}").size).to eq 0x10F800 - orig.size
      expect(CharacterSet.send("non_#{name}").intersect?(orig)).to be false
      expect(CharacterSet.send("non_#{name}")).to be_frozen
    end
  end

  describe '::ascii' do
    it 'includes all ASCII codepoints' do
      expect(CharacterSet.ascii.size).to eq 0x80
      expect(CharacterSet.ascii).to include 'a'
      expect(CharacterSet.ascii).to include '1'
      # `not_to include` is extremely slow for some reason?!
      expect(CharacterSet.ascii.include?('ü')).to be false
    end

    it_behaves_like :predefined_character_set, :ascii
  end

  # these tests are slow on java, the one above shall suffice
  next if RUBY_PLATFORM[/java/i]

  describe '::ascii_alnum' do
    it 'includes all ASCII letters and numbers' do
      expect(CharacterSet.ascii_alnum.size).to eq 62
      expect(CharacterSet.ascii_alnum).to include 'a'
      expect(CharacterSet.ascii_alnum).to include '1'
      expect(CharacterSet.ascii_alnum.include?('.')).to be false
      expect(CharacterSet.ascii_alnum.include?('ü')).to be false
    end

    it_behaves_like :predefined_character_set, :ascii_alnum
  end

  describe '::ascii_letter' do
    it 'includes all ASCII letters' do
      expect(CharacterSet.ascii_letter.size).to eq 52
      expect(CharacterSet.ascii_letter).to include 'a'
      expect(CharacterSet.ascii_letter.include?('1')).to be false
      expect(CharacterSet.ascii_letter.include?('.')).to be false
      expect(CharacterSet.ascii_letter.include?('ü')).to be false
    end

    it_behaves_like :predefined_character_set, :ascii_letter
  end

  describe '::bmp' do
    it 'includes all basic multilingual plane codepoints' do
      expect(CharacterSet.bmp.size).to eq 0x10000 - 0x800
      expect(CharacterSet.bmp).to include 'a'
      expect(CharacterSet.bmp).to include '1'
      expect(CharacterSet.bmp).to include 'ü'
      expect(CharacterSet.bmp.include?(0x10000)).to be false
    end

    it_behaves_like :predefined_character_set, :bmp
  end

  describe '::crypt' do
    it 'includes all unicode codepoints commonly used in crypt strings' do
      expect(CharacterSet.crypt.map(&:chr).join)
        .to eq "./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    end

    it_behaves_like :predefined_character_set, :crypt
  end

  describe '::emoji' do
    it 'includes all emoji codepoints' do
      expect(CharacterSet.emoji.include?('a')).to be false
      expect(CharacterSet.emoji).to include '😋'
    end

    it_behaves_like :predefined_character_set, :emoji
  end

  describe '::newline' do
    it 'includes all newline codepoints' do
      expect(CharacterSet.newline).to include "\n"
      expect(CharacterSet.newline).to include "\r"
    end

    it_behaves_like :predefined_character_set, :newline
  end

  describe '::unicode' do
    it 'includes all valid unicode codepoints' do
      expect(CharacterSet.unicode.size).to eq 0x110000 - 0x800
      expect(CharacterSet.unicode).to include 'a'
      expect(CharacterSet.unicode).to include '😋'
    end

    it_behaves_like :predefined_character_set, :unicode
  end

  describe '::url_fragment' do
    it 'includes all unicode codepoints that are valid in a URL fragment' do
      expect(CharacterSet.url_fragment.map(&:chr).join)
        .to eq "!$&'()*+,-./0123456789:;=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"
    end

    it_behaves_like :predefined_character_set, :url_fragment
  end

  describe '::url_host' do
    it 'includes all unicode codepoints that are valid in a URL host' do
      expect(CharacterSet.url_host.map(&:chr).join)
        .to eq "!$&'()*+,-.0123456789:;=ABCDEFGHIJKLMNOPQRSTUVWXYZ[]_abcdefghijklmnopqrstuvwxyz~"
    end

    it_behaves_like :predefined_character_set, :url_host
  end

  describe '::url_path' do
    it 'includes all unicode codepoints that are valid in a URL path' do
      expect(CharacterSet.url_path.map(&:chr).join)
        .to eq "!$%&'()*+,-./0123456789:=@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"
    end

    it_behaves_like :predefined_character_set, :url_path
  end

  describe '::url_query' do
    it 'includes all unicode codepoints that are valid in a URL query' do
      expect(CharacterSet.url_query.map(&:chr).join)
        .to eq "!$&'()*+,-./0123456789:;=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz~"
    end

    it_behaves_like :predefined_character_set, :url_query
  end

  describe '::whitespace' do
    it 'includes all whitespace codepoints' do
      expect(CharacterSet.whitespace).to include ' '
      expect(CharacterSet.whitespace).to include "\n"
    end

    it_behaves_like :predefined_character_set, :whitespace
  end
end

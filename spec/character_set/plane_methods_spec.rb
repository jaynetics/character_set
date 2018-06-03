RSpec.describe CharacterSet::PlaneMethods do
  describe '#bmp_part' do
    it 'returns the basic monolingual plane part of a character set' do
      expect(CharacterSet[97, 98, 99, 70_000, 70_001].bmp_part)
        .to eq(CharacterSet[97, 98, 99])
    end
  end

  describe '#astral_part' do
    it 'returns the astral planes part of a character set' do
      expect(CharacterSet[97, 98, 99, 70_000, 70_001].astral_part)
        .to eq(CharacterSet[70_000, 70_001])
    end
  end

  describe '#bmp_part?' do
    it 'returns true iff a part of the character set is in the bmp' do
      expect(CharacterSet[97, 98, 99].bmp_part?).to be true
      expect(CharacterSet[97, 98, 99, 70_000, 70_001].bmp_part?).to be true
      expect(CharacterSet[70_000, 70_001].bmp_part?).to be false
      expect(CharacterSet[].bmp_part?).to be false
    end
  end

  describe '#astral_part?' do
    it 'returns true iff a part of the character set is astral' do
      expect(CharacterSet[97, 98, 99].astral_part?).to be false
      expect(CharacterSet[97, 98, 99, 70_000, 70_001].astral_part?).to be true
      expect(CharacterSet[70_000, 70_001].astral_part?).to be true
      expect(CharacterSet[].astral_part?).to be false
    end
  end

  describe '#bmp_ratio' do
    it 'returns the ratio of characters in the bmp' do
      expect(CharacterSet[97, 98, 99, 70_000, 70_001].bmp_ratio).to eq 0.6
    end
  end

  describe '#astral_ratio' do
    it 'returns the ratio of characters in the bmp' do
      expect(CharacterSet[97, 98, 99, 70_000, 70_001].astral_ratio).to eq 0.4
    end
  end

  describe '#member_in_plane?' do
    it 'returns true iff the CharacterSet has a member in the given plane' do
      expect(CharacterSet[97, 98, 99].member_in_plane?(0)).to be true
      expect(CharacterSet[97, 98, 99].member_in_plane?(1)).to be false
      expect(CharacterSet[70_000, 70_001].member_in_plane?(0)).to be false
      expect(CharacterSet[70_000, 70_001].member_in_plane?(1)).to be true
    end
  end
end

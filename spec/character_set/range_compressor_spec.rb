RSpec.describe CharacterSet::RangeCompressor do
  RangeCompressor = CharacterSet::RangeCompressor

  describe '::compress' do
    it 'takes only SortedSets' do
      expect { RangeCompressor.compress(Set[]) }.to raise_error
      expect { RangeCompressor.compress(SortedSet[]) }.not_to raise_error
    end

    it 'returns an Array of Ranges, split based on contiguity' do
      expect(RangeCompressor.compress(SortedSet[]))
        .to eq []

      expect(RangeCompressor.compress(SortedSet[1, 2, 3]))
        .to eq [1..3]

      expect(RangeCompressor.compress(SortedSet[1, 3]))
        .to eq [1..1, 3..3]

      expect(RangeCompressor.compress(SortedSet[0, 2, 3, 4, 6, 8, 11, 12]))
        .to eq [
          0..0,
          2..4,
          6..6,
          8..8,
          11..12,
        ]
    end
  end
end

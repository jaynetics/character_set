RSpec.describe CharacterSet do
  it 'has a version number' do
    expect(CharacterSet::VERSION).not_to be nil
  end

  describe '#initialize' do
    it 'gets data via Reader::codepoints_from_enumerable' do
      expect(CharacterSet::Reader)
        .to receive(:codepoints_from_enumerable)
        .and_return([42])

      expect(CharacterSet.new('foo').to_a).to eq [42]
    end

    it 'gets called by ::[]' do
      expect(CharacterSet::Reader)
        .to receive(:codepoints_from_enumerable)
        .and_return([42])

      expect(CharacterSet['foo'].to_a).to eq [42]
    end
  end

  describe '::read' do
    it 'gets data via Reader::codepoints_from_bracket_expression' do
      expect(CharacterSet::Reader)
        .to receive(:codepoints_from_bracket_expression)
        .and_return([42])

      expect(CharacterSet.read('foo').to_a).to eq [42]
    end

    it 'inverts the result if the argument is a negative bracket expression' do
      result = CharacterSet.read('[^a]')
      expect(result.count).to be > 1_000_000
      expect(result).not_to include 97 # 'a'
      expect(result).to     include 98 # 'b'
    end
  end

  describe '#to_s' do
    it 'calls CharacterSet::Writer::write' do
      expect(CharacterSet::Writer).to receive(:write).and_return(42)
      expect(CharacterSet[].to_s).to eq 42
    end
  end

  describe '#to_s_with_surrogate_pair_alternation' do
    it 'calls CharacterSet::Writer::write_surrogate_pair_alternation' do
      expect(CharacterSet::Writer)
        .to receive(:write_surrogate_pair_alternation)
        .and_return(42)
      expect(CharacterSet[].to_s_with_surrogate_pair_alternation).to eq 42
    end
  end

  describe '#ranges' do
    it 'calls CharacterSet::RangeCompressor::compress, passing itself' do
      set = CharacterSet[]
      expect(CharacterSet::RangeCompressor)
        .to receive(:compress)
        .with(set)
        .and_return(42)
      expect(set.ranges).to eq 42
    end
  end

  it 'has a not-to-verbose #inspect' do
    expect(CharacterSet[97, 98, 99].inspect).to eq '#<CharacterSet (size: 3)>'
  end
end

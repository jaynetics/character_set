class CharacterSet < SortedSet
  module CommonSets
    def ascii
      @ascii ||= new.fill(upto: 0x7F, ucp_only: true)
    end

    def newlines
      @newlines ||= new([0x0A, 0x0B, 0x0C, 0x0D, 0x85, 0x2028, 0x2029])
    end

    def unicode
      @unicode ||= new.fill(upto: 0x10FFFF, ucp_only: true)
    end
  end
end

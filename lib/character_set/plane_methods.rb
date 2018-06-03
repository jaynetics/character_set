class CharacterSet < SortedSet
  module PlaneMethods
    PLANE_SIZE = 0x10000

    def bmp_part
      @bmp_part ||=
        self.class.new(@hash.each_key.take_while { |cp| cp < PLANE_SIZE })
    end

    def astral_part
      @astral_part ||=
        self.class.new(@hash.each_key.drop_while { |cp| cp < PLANE_SIZE })
    end

    def bmp_part?
      !bmp_part.empty?
    end

    def astral_part?
      !astral_part.empty?
    end

    def bmp_ratio
      bmp_part.count / count.to_f
    end

    def astral_ratio
      astral_part.count / count.to_f
    end

    # cumbersome, but much less wasteful than #any? / #find
    def member_in_plane?(number)
      lo_bound = number * PLANE_SIZE
      hi_bound = (number + 1) * PLANE_SIZE
      each do |cp|
        next if cp < lo_bound
        return false if cp > hi_bound
        return true
      end
      false
    end
  end
end

class CharacterSet
  PLANE_SIZE = 0x10000

  module PlaneMethods
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
  end
end

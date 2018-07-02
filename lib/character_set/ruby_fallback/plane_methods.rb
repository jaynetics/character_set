class CharacterSet
  module RubyFallback
    module PlaneMethods
      def bmp_part
        dup.keep_if { |cp| cp < 0x10000 }
      end

      def astral_part
        dup.keep_if { |cp| cp >= 0x10000 }
      end

      def planes
        plane_set = {}
        plane_size = 0x10000.to_f
        each do |cp|
          plane = (cp / plane_size).floor
          plane_set[plane] = true
        end
        plane_set.keys
      end

      def member_in_plane?(num)
        ((num * 0x10000)...((num + 1) * 0x10000)).any? { |cp| include?(cp) }
      end
    end
  end
end

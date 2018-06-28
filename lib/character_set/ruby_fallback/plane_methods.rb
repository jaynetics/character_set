class CharacterSet
  module RubyFallback
    module PlaneMethods
      def bmp_part
        @bmp_part ||= dup.keep_if { |cp| cp < PLANE_SIZE }
      end

      def astral_part
        @astral_part ||= dup.keep_if { |cp| cp >= PLANE_SIZE }
      end

      def planes
        plane_set = {}
        div = PLANE_SIZE.to_f
        each do |cp|
          plane = (cp / div).floor
          plane_set[plane] = true
        end
        plane_set.keys
      end

      def member_in_plane?(num)
        ((num * PLANE_SIZE)...((num + 1) * PLANE_SIZE)).any? { |cp| include?(cp) }
      end
    end
  end
end

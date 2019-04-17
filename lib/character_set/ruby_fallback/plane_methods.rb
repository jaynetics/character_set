class CharacterSet
  module RubyFallback
    module PlaneMethods
      {
        ascii:  0..0x7F,
        bmp:    0..0xFFFF,
        astral: 0x10000..0x10FFFF,
      }.each do |section, range|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{section}_part
            dup.keep_if { |cp| (#{range}).cover?(cp) }
          end

          def #{section}_part?
            any? { |cp| (#{range}).cover?(cp) }
          end

          def #{section}_only?
            none? { |cp| !(#{range}).cover?(cp) }
          end

          def #{section}_ratio
            #{section}_part.count / count.to_f
          end
        RUBY
      end

      def planes
        plane_size = 0x10000.to_f
        inject({}) { |hash, cp| hash.merge((cp / plane_size).floor => 1) }.keys
      end

      def plane(num)
        validate_plane_number(num)
        range = ((num * 0x10000)...((num + 1) * 0x10000))
        dup.keep_if { |cp| range.cover?(cp) }
      end

      def member_in_plane?(num)
        validate_plane_number(num)
        ((num * 0x10000)...((num + 1) * 0x10000)).any? { |cp| include?(cp) }
      end

      private

      def validate_plane_number(num)
        num >= 0 && num <= 16 or raise ArgumentError, 'plane must be between 0 and 16'
      end
    end
  end
end

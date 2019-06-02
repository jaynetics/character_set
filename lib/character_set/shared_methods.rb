#
# Various methods shared by the pure-Ruby and the extended implementation.
#
# Many of these methods are hotspots, so they are defined directly on
# the including classes for better performance.
#
class CharacterSet
  module SharedMethods
    def self.included(klass)
      klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        LoadError = Class.new(::LoadError)

        class << self
          def [](*args)
            new(Array(args))
          end

          def parse(string)
            codepoints = Parser.codepoints_from_bracket_expression(string)
            result = new(codepoints)
            string.start_with?('[^') ? result.inversion : result
          end

          def of_property(property_name)
            require_optional_dependency('regexp_property_values')

            property = RegexpPropertyValues[property_name.to_s]
            from_ranges(*property.matched_ranges)
          end

          def of_regexp(regexp)
            require_optional_dependency('regexp_parser')

            root = ::Regexp::Parser.parse(regexp)
            of_expression(root)
          end

          def of_expression(expression)
            ExpressionConverter.convert(expression)
          end

          def require_optional_dependency(name)
            required_optional_dependencies[name] ||= begin
              require name
              true
            rescue ::LoadError
              entry_point = caller_locations.reverse.find do |loc|
                loc.absolute_path.to_s.include?('/lib/character_set')
              end
              method = entry_point && entry_point.label
              raise LoadError, 'You must the install the optional dependency '\
                               "'\#{name}' to use the method `\#{method}'."
            end
          end

          def required_optional_dependencies
            @required_optional_dependencies ||= {}
          end
        end # class << self

        def initialize(enumerable = [])
          merge(Parser.codepoints_from_enumerable(enumerable))
        end

        def replace(enum)
          unless [Array, CharacterSet, Range].include?(enum.class)
            enum = self.class.new(enum)
          end
          clear
          merge(enum)
        end

        # CharacterSet-specific conversion methods

        def assigned_part
          self & self.class.assigned
        end

        def valid_part
          self - self.class.surrogate
        end

        # CharacterSet-specific stringification methods

        def to_s(opts = {}, &block)
          Writer.write(ranges, opts, &block)
        end

        def to_s_with_surrogate_ranges
          Writer.write_surrogate_ranges(bmp_part.ranges, astral_part.ranges)
        end

        def to_s_with_surrogate_alternation
          Writer.write_surrogate_alternation(bmp_part.ranges, astral_part.ranges)
        end

        def inspect
          len = length
          "#<#{klass.name}: {\#{first(5) * ', '}\#{'...' if len > 5}} (size: \#{len})>"
        end

        # C-extension adapter methods. Need overriding in pure fallback.
        # Parsing kwargs in C is slower, verbose, and kinda deprecated.

        def inversion(include_surrogates: false, upto: 0x10FFFF)
          ext_inversion(include_surrogates, upto)
        end

        def section(from:, upto: 0x10FFFF)
          ext_section(from, upto)
        end

        def count_in_section(from:, upto: 0x10FFFF)
          ext_count_in_section(from, upto)
        end

        def section?(from:, upto: 0x10FFFF)
          ext_section?(from, upto)
        end

        def section_ratio(from:, upto: 0x10FFFF)
          ext_section_ratio(from, upto)
        end

        #
        # The following methods are here for `Set` compatibility, but they are
        # comparatively slow. Prefer others.
        #
        def map!
          block_given? or return enum_for(__method__) { size }
          arr = []
          each { |cp| arr << yield(cp) }
          replace(arr)
        end
        alias collect! map!

        def reject!(&block)
          block_given? or return enum_for(__method__) { size }
          old_size = size
          delete_if(&block)
          self if size != old_size
        end

        def select!(&block)
          block_given? or return enum_for(__method__) { size }
          old_size = size
          keep_if(&block)
          self if size != old_size
        end
        alias filter! select!

        def classify
          block_given? or return enum_for(__method__) { size }
          each_with_object({}) { |cp, h| (h[yield(cp)] ||= self.class.new).add(cp) }
        end

        def divide(&func)
          require 'set'
          Set.new(to_a).divide(&func)
        end
      RUBY

      # CharacterSet-specific section methods

      {
        ascii:  0..0x7F,
        bmp:    0..0xFFFF,
        astral: 0x10000..0x10FFFF,
      }.each do |section_name, range|
        klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{section_name}_part
            section(from: #{range.begin}, upto: #{range.end})
          end

          def #{section_name}_part?
            section?(from: #{range.begin}, upto: #{range.end})
          end

          def #{section_name}_only?
            #{range.begin == 0 ?
              "!section?(from: #{range.end}, upto: 0x10FFFF)" :
              "!section?(from: 0, upto: #{range.begin})"}
          end

          def #{section_name}_ratio
            section_ratio(from: #{range.begin}, upto: #{range.end})
          end
        RUBY
      end
    end # self.included
  end # SharedMethods
end

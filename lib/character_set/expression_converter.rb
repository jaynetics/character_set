class CharacterSet
  module ExpressionConverter
    module_function

    Error = Class.new(ArgumentError)

    def convert(expression)
      CharacterSet.require_optional_dependency('regexp_parser')

      case expression
      when Regexp::Expression::Root
        if expression.count != 1
          raise Error, 'Pass a Regexp with exactly one expression, e.g. /[a-z]/'
        end
        convert(expression[0])

      when Regexp::Expression::CharacterSet
        content = expression.map { |subexp| convert(subexp) }.reduce(:+)
        expression.negative? ? content.inversion : content

      when Regexp::Expression::CharacterSet::Intersection
        expression.map { |subexp| convert(subexp) }.reduce(:&)

      when Regexp::Expression::CharacterSet::IntersectedSequence
        expression.map { |subexp| convert(subexp) }.reduce(:+)

      when Regexp::Expression::CharacterSet::Range
        start, finish = expression.map { |subexp| convert(subexp) }
        CharacterSet.new((start.min)..(finish.max))

      when Regexp::Expression::CharacterType::Any
        CharacterSet.unicode

      when Regexp::Expression::CharacterType::Base
        /(?<negative>non)?(?<base_name>.+)/ =~ expression.token
        content =
          if expression.unicode_classes?
            # in u-mode, type shortcuts match the same as \p{<long type name>}
            CharacterSet.of_property(base_name)
          else
            # in normal mode, types match only ascii chars
            case base_name.to_sym
            when :digit then CharacterSet.from_ranges(48..57)
            when :hex   then CharacterSet.from_ranges(48..57, 65..70, 97..102)
            when :space then CharacterSet.from_ranges(9..13, 32..32)
            when :word  then CharacterSet.from_ranges(48..57, 65..90, 95..95, 97..122)
            else raise Error, "Unsupported CharacterType #{base_name}"
            end
          end
        negative ? content.inversion : content

      when Regexp::Expression::EscapeSequence::CodepointList
        CharacterSet.new(expression.codepoints)

      when Regexp::Expression::EscapeSequence::Base
        CharacterSet[expression.codepoint]

      when Regexp::Expression::Group::Capture,
           Regexp::Expression::Group::Passive,
           Regexp::Expression::Group::Named,
           Regexp::Expression::Group::Atomic,
           Regexp::Expression::Group::Options
        case expression.count
        when 0 then CharacterSet[]
        when 1 then convert(expression.first)
        else
          raise Error, 'Groups must contain exactly one expression, e.g. ([a-z])'
        end

      when Regexp::Expression::Alternation
        expression.map { |subexp| convert(subexp) }.reduce(:+)

      when Regexp::Expression::Alternative
        case expression.count
        when 0 then CharacterSet[]
        when 1 then convert(expression.first)
        else
          raise Error, 'Alternatives must contain exactly one expression'
        end

      when Regexp::Expression::Literal
        if expression.set_level == 0 && expression.text.size != 1
          raise Error, 'Literal runs outside of sets are codepoint *sequences*'
        end
        CharacterSet[expression.text.ord]

      when Regexp::Expression::UnicodeProperty::Base,
           Regexp::Expression::PosixClass
        content = CharacterSet.of_property(expression.token)
        if expression.type == :posixclass && expression.ascii_classes?
          content = content.ascii_part
        end
        expression.negative? ? content.inversion : content

      when Regexp::Expression::Base
        raise Error, "Unsupported expression class `#{expression.class}`"

      else
        raise Error, "Pass an expression (result of Regexp::Parser.parse)"
      end
    end
  end
end

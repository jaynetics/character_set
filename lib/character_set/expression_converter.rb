class CharacterSet
  module ExpressionConverter
    module_function

    Error = Class.new(ArgumentError)

    def convert(expression, to = CharacterSet, acc = [])
      CharacterSet.require_optional_dependency('regexp_parser', __method__)

      case expression
      when Regexp::Expression::CharacterSet
        content = expression.map { |subexp| convert(subexp, to) }.reduce(:+) || to[]
        acc << (expression.negative? ? content.inversion : content)

      when Regexp::Expression::CharacterSet::Intersection
        acc << expression.map { |subexp| convert(subexp, to) }.reduce(:&)

      when Regexp::Expression::CharacterSet::Range
        start, finish = expression.map { |subexp| convert(subexp, to) }
        acc << to.new((start.min)..(finish.max))

      when Regexp::Expression::Subexpression # root, group, alternation, etc.
        expression.each { |subexp| convert(subexp, to, acc) }

      when Regexp::Expression::CharacterType::Any
        acc << to.unicode

      when Regexp::Expression::CharacterType::Base
        /(?<negative>non)?(?<base_name>.+)/ =~ expression.token
        content =
          if expression.unicode_classes?
            # in u-mode, most type shortcuts match the same as \p{<long type name>}
            if base_name == 'linebreak'
              to.from_ranges(10..13, 133..133, 8232..8233)
            else
              to.of_property(base_name)
            end
          else
            # in normal mode, types match only ascii chars
            case base_name.to_sym
            when :digit     then to.from_ranges(48..57)
            when :hex       then to.from_ranges(48..57, 65..70, 97..102)
            when :linebreak then to.from_ranges(10..13)
            when :space     then to.from_ranges(9..13, 32..32)
            when :word      then to.from_ranges(48..57, 65..90, 95..95, 97..122)
            else raise Error, "Unsupported CharacterType #{base_name}"
            end
          end
        acc << (negative ? content.inversion : content)

      when Regexp::Expression::EscapeSequence::CodepointList
        content = to.new(expression.codepoints)
        acc << (expression.i? ? content.case_insensitive : content)

      when Regexp::Expression::EscapeSequence::Base
        content = to[expression.codepoint]
        acc << (expression.i? ? content.case_insensitive : content)

      when Regexp::Expression::Literal
        content = to[*expression.text.chars]
        acc << (expression.i? ? content.case_insensitive : content)

      when Regexp::Expression::UnicodeProperty::Base,
           Regexp::Expression::PosixClass
        content = to.of_property(expression.token)
        if expression.type == :posixclass && expression.ascii_classes?
          content = content.ascii_part
        end
        acc << (expression.negative? ? content.inversion : content)

      when Regexp::Expression::Anchor::Base,
           Regexp::Expression::Backreference::Base,
           Regexp::Expression::Keep::Mark,
           Regexp::Expression::Quantifier
        # ignore zero-length and repeat expressions

      when Regexp::Expression::Base
        raise Error, "Unsupported expression class `#{expression.class}`"

      else
        raise Error, 'Pass an expression (result of Regexp::Parser.parse)'
      end

      acc.reduce(:+) || to[]
    end
  end
end

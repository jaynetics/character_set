class CharacterSet
  class Character
    ENCODING = 'utf-8'.freeze
    SAFELY_PRINTABLE = (0x21..0x7E).to_a - %w(- / [ \\ ] ^).map(&:ord)

    attr_accessor :codepoint

    def initialize(codepoint)
      case codepoint
      when Integer then self.codepoint = codepoint
      when String  then self.codepoint = codepoint.ord
      else              raise ArgumentError, 'pass an Integer or String'
      end
    end

    def to_s
      codepoint.chr(ENCODING)
    end

    def hex
      codepoint.to_s(16).upcase
    end

    def escape(opts = {})
      return to_s if SAFELY_PRINTABLE.include?(codepoint) && !opts[:escape_all]

      return yield(self) if block_given?

      # https://billposer.org/Software/ListOfRepresentations.html
      case opts[:format].to_s.downcase.delete('-_ ')
      when '', 'default', 'es6', 'esnext', 'rb', 'ruby'
        default_escape(opts)
      when 'java', 'javascript', 'js'
        default_escape(opts, false)
      when 'capitalizableu', 'c#', 'csharp', 'd', 'python'
        capitalizable_u_escape
      when 'u+', 'uplus'
        u_plus_escape
      when 'literal', 'raw'
        to_s
      else
        raise ArgumentError, "unsupported format: #{opts[:format].inspect}"
      end
    end

    def plane
      codepoint / 0x10000
    end

    private

    def default_escape(opts, support_wide_hex = true)
      if hex.length <= 2
        '\\x' + hex.rjust(2, '0')
      elsif hex.length <= 4
        '\\u' + hex.rjust(4, '0')
      elsif support_wide_hex
        '\\u{' + hex + '}'
      else
        raise "#{opts[:format]} does not support escaping astral value #{hex}"
      end
    end

    def capitalizable_u_escape
      if hex.length <= 4
        '\\u' + hex.rjust(4, '0')
      else
        '\\U' + hex.rjust(8, '0')
      end
    end

    def u_plus_escape
      'U+' + hex.rjust(4, '0')
    end
  end
end

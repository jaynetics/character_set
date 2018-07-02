class CharacterSet
  module SetMethodAdapters
    # Allow some methods to work with String in addition to Integer args
    # (the internal representation is geared towards codepoint Integers).
    %w[add add? << delete delete? include? member? ===].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(arg)
          case arg
          when String
            super(arg.ord)
          when Integer
            if arg < 0 || arg > 0x10FFFF
              raise ArgumentError, 'pass an Integer between 0 and 0x10FFFF'
            end
            super(arg)
          else
            raise ArgumentError, 'pass a String or an Integer'
          end
        end
      RUBY
    end

    # Allow some methods to take an Enum just as well as another CharacterSet.
    # Tested by ruby-spec.
    %w[& + - ^ | difference intersection subtract union].each do |method|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(arg)
          if arg.is_a?(CharacterSet)
            super
          elsif arg.respond_to?(:each)
            super(CharacterSet.new(arg.to_a))
          else
            raise ArgumentError, 'pass an enumerable'
          end
        end
      RUBY
    end
  end
end

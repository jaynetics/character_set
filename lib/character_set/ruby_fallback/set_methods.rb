class CharacterSet
  module RubyFallback
    module SetMethods
      Enumerable.instance_methods.concat(%w[empty? length size]).each do |mthd|
        define_method(mthd) do |*args, &block|
          @__set.__send__(mthd, *args, &block)
        end
      end

      %w[< <= > >= proper_subset? proper_superset?
         subset? superset?].each do |mthd|
        define_method(mthd) do |enum, &block|
          enum = enum.instance_variable_get(:@__set) if enum.is_a?(CharacterSet)
          @__set.__send__(mthd, enum, &block)
        end
      end

      %w[<< === add add? clear collect! delete delete? delete_if each
         filter! hash include? map! member? merge keep_if reject!
         select! subtract].each do |mthd|
        define_method(mthd) do |*args, &block|
          result = @__set.__send__(mthd, *args, &block)
          result.is_a?(Set) ? self : result
        end
      end

      %w[& + - ^ | difference intersection union].each do |mthd|
        define_method(mthd) do |enum, &block|
          if enum.respond_to?(:map)
            enum = enum.map { |el| el.is_a?(String) ? el.ord : el }
          end
          self.class.new(@__set.__send__(mthd, enum, &block).to_a)
        end
      end

      %w[freeze taint untaint].each do |mthd|
        define_method(mthd) do
          @__set.__send__(mthd)
          super
        end
      end

      def ==(other)
        if equal?(other)
          true
        elsif other.instance_of?(self.class)
          @__set == other.instance_variable_get(:@__set)
        elsif other.is_a?(self.class) && size == other.size
          other.all? { |cp| @__set.include?(cp) }
        else
          false
        end
      end

      def eql?(other)
        return false unless other.is_a?(self.class)
        @__set.eql?(other.instance_variable_get(:@__set))
      end

      def initialize_dup(orig)
        super
        @__set = orig.instance_variable_get(:@__set).dup
      end

      def initialize_clone(orig)
        super
        @__set = orig.instance_variable_get(:@__set).clone
      end

      def to_a(stringify = false)
        result = @__set.to_a
        stringify ? result.map { |cp| cp.chr('utf-8') } : result
      end
    end
  end
end

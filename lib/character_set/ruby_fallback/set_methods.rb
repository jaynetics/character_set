class CharacterSet
  module RubyFallback
    module SetMethods
      Enumerable.instance_methods.concat(%w[empty? length size]).each do |mthd|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{mthd}(*args, &block)
            @__set.#{mthd}(*args, &block)
          end
        RUBY
      end

      %w[< <= > >= disjoint? intersect? proper_subset? proper_superset?
         subset? superset?].each do |mthd|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{mthd}(enum, &block)
            if enum.is_a?(CharacterSet) || enum.is_a?(CharacterSet::Pure)
              enum = enum.instance_variable_get(:@__set)
            end
            @__set.#{mthd}(enum, &block)
          end
        RUBY
      end

      %w[<< === add add? clear collect! delete delete? delete_if
         each filter! hash include? map! member? keep_if reject!
         select! subtract].each do |mthd|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{mthd}(*args, &block)
            result = @__set.#{mthd}(*args, &block)
            result.is_a?(Set) ? self : result
          end
        RUBY
      end

      %w[& + - ^ | difference intersection union].each do |mthd|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{mthd}(enum, &block)
            if enum.respond_to?(:map)
              enum = enum.map { |el| el.is_a?(String) ? el.ord : el }
            end
            self.class.new(@__set.#{mthd}(enum, &block).to_a)
          end
        RUBY
      end

      %w[taint untaint].each do |mthd|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{mthd}
            @__set.#{mthd}
            super
          end
        RUBY
      end

      unless RUBY_PLATFORM[/java/i]
        def freeze
          @__set.to_a
          @__set.freeze
          super
        end
      end

      def merge(other)
        raise ArgumentError, 'pass an Enumerable' unless other.respond_to?(:each)
        # pass through #add to use the checks in SetMethodAdapters
        other.each { |e| add(e) }
        self
      end

      def ==(other)
        if equal?(other)
          true
        elsif other.instance_of?(self.class)
          @__set == other.instance_variable_get(:@__set)
        elsif other.is_a?(CharacterSet) || other.is_a?(CharacterSet::Pure)
          size == other.size && other.all? { |cp| @__set.include?(cp) }
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

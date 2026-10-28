class CharacterSet
  module RubyFallback
    # Set-like methods, backed by a Hash of codepoints (@__hash) and a
    # memoized, sorted Array of its keys (@__keys) that mutators reset.
    module SetMethods
      # Delegate Enumerable methods to the sorted keys Array. This is faster
      # than the Enumerable implementations that go through #each, and it
      # keeps CharacterSet::Pure free of C-implemented methods.
      (Enumerable.instance_methods - %i[each include? member? to_a]).each do |mthd|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{mthd}(...)
            sorted_keys.#{mthd}(...)
          end
        RUBY
      end

      def each(&block)
        block or return enum_for(__method__) { size }
        sorted_keys.each(&block)
        self
      end

      def to_a(stringify = false)
        stringify ? sorted_keys.map { |cp| cp.chr('utf-8') } : sorted_keys.dup
      end

      def size
        @__hash.size
      end
      alias length size

      def empty?
        @__hash.empty?
      end

      def hash
        @__hash.hash
      end

      def include?(cp)
        @__hash.key?(cp)
      end
      alias member? include?
      alias === include?

      def add(cp)
        @__hash[cp] = true
        @__keys = nil
        self
      end
      alias << add

      def add?(cp)
        assert_not_frozen
        add(cp) unless include?(cp)
      end

      def delete(cp)
        @__keys = nil if @__hash.delete(cp)
        self
      end

      def delete?(cp)
        assert_not_frozen
        delete(cp) if include?(cp)
      end

      def clear
        @__hash.clear
        @__keys = nil
        self
      end

      def keep_if
        assert_not_frozen
        block_given? or return enum_for(__method__) { size }
        old_size = size
        sorted_keys.each { |cp| @__hash.delete(cp) unless yield(cp) }
        @__keys = nil if size != old_size
        self
      end

      def delete_if
        assert_not_frozen
        block_given? or return enum_for(__method__) { size }
        keep_if { |cp| !yield(cp) }
      end

      def merge(other)
        assert_not_frozen
        raise ArgumentError, 'pass an Enumerable' unless other.respond_to?(:each)

        if (other_hash = codepoint_hash(other))
          # Members of another CharacterSet are valid codepoints already,
          # so they can go in with one Hash#update instead of n adds.
          @__hash.update(other_hash)
          @__keys = nil
        else
          # pass through #add to use the checks in SetMethodAdapters
          other.each { |e| add(e) }
        end
        self
      end

      # The operands of the following methods are always CharacterSets,
      # ensured by SetMethodAdapters - but they might be C-backed, so
      # only their public interface is used.

      def subtract(other)
        other.each { |cp| @__hash.delete(cp) }
        @__keys = nil
        self
      end

      def |(other)
        dup.merge(other)
      end
      alias + |
      alias union |

      def -(other)
        dup.subtract(other)
      end
      alias difference -

      def &(other)
        result = self.class.new
        # Fresh results have no memoized keys yet, so their Hash can be
        # filled directly.
        result_hash = codepoint_hash(result)
        small, large = size < other.size ? [self, other] : [other, self]
        large = lookup(large)
        small.each { |cp| result_hash[cp] = true if large.include?(cp) }
        result
      end
      alias intersection &

      def ^(other)
        (self | other) - (self & other)
      end

      def intersect?(other)
        small, large = size < other.size ? [self, other] : [other, self]
        large = lookup(large)
        small.any? { |cp| large.include?(cp) }
      end

      def disjoint?(other)
        !intersect?(other)
      end

      def <=>(other)
        return unless character_set?(other)

        case size <=> other.size
        when -1 then -1 if proper_subset?(other)
        when +1 then +1 if proper_superset?(other)
        else 0 if self == other
        end
      end

      def subset?(other)
        assert_character_set(other)
        return false if size > other.size

        other = lookup(other)
        all? { |cp| other.include?(cp) }
      end
      alias <= subset?

      def proper_subset?(other)
        assert_character_set(other)
        return false if size >= other.size

        other = lookup(other)
        all? { |cp| other.include?(cp) }
      end
      alias < proper_subset?

      def superset?(other)
        assert_character_set(other)
        size >= other.size && other.all? { |cp| @__hash.key?(cp) }
      end
      alias >= superset?

      def proper_superset?(other)
        assert_character_set(other)
        size > other.size && other.all? { |cp| @__hash.key?(cp) }
      end
      alias > proper_superset?

      def ==(other)
        if equal?(other)
          true
        elsif (other_hash = codepoint_hash(other))
          @__hash == other_hash
        elsif character_set?(other)
          size == other.size && other.all? { |cp| @__hash.key?(cp) }
        else
          false
        end
      end

      def eql?(other)
        other.is_a?(self.class) && @__hash.eql?(codepoint_hash(other))
      end

      def freeze
        sorted_keys.freeze
        @__hash.freeze
        super
      end

      def initialize_dup(orig)
        super
        @__hash = @__hash.dup
        @__keys = nil # dups are usually mutated, so don't bother copying
      end

      def initialize_clone(orig, freeze: nil)
        super
        @__hash = @__hash.clone(freeze: freeze)
        @__keys = @__keys&.clone(freeze: freeze)
      end

      private

      def sorted_keys
        @__keys ||= @__hash.keys.sort!
      end

      def character_set?(obj)
        obj.is_a?(CharacterSet) ||
          defined?(CharacterSet::Pure) && obj.is_a?(CharacterSet::Pure)
      end

      def assert_character_set(obj)
        character_set?(obj) or raise ArgumentError, 'value must be a set'
      end

      def assert_not_frozen
        raise FrozenError, "can't modify frozen #{self.class}" if frozen?
      end

      # The codepoint Hash of another Ruby-backed CharacterSet, or nil if
      # `other` is not a CharacterSet - or is C-backed and so has no Hash.
      def codepoint_hash(other)
        other.instance_variable_get(:@__hash) if character_set?(other)
      end

      # The cheapest object that answers #include? for the codepoints of
      # `set`: its Hash if it is Ruby-backed, which skips the argument checks
      # of SetMethodAdapters, otherwise the set itself.
      def lookup(set)
        codepoint_hash(set) || set
      end
    end
  end
end

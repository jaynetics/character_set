class CharacterSet
  module SetMethods
    def replace(enum)
      unless [Array, CharacterSet, Range].include?(enum.class)
        enum = self.class.new(enum)
      end
      clear
      merge(enum)
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
      block_given? or return enum_for(__method__) { size }
      require 'set'

      if func.arity == 2
        require 'tsort'

        class << dig = {}
          include TSort

          alias tsort_each_node each_key
          def tsort_each_child(node, &block)
            fetch(node).each(&block)
          end
        end

        each do |u|
          dig[u] = a = []
          each{ |v| a << v if yield(u, v) }
        end

        set = Set.new
        dig.each_strongly_connected_component do |css|
          set.add(self.class.new(css))
        end
        set
      else
        Set.new(classify(&func).values)
      end
    end
  end
end

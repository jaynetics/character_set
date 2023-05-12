# set, vendored from https://github.com/ruby/set/blob/master/lib/set.rb,
# with comments removed and linted.
class CharacterSet::RubyFallback::Set
  Set = self
  include Enumerable

  def self.[](*ary)
    new(ary)
  end

  def initialize(enum = nil, &block)
    @hash = Hash.new(false)

    enum.nil? and return

    if block
      do_with_enum(enum) { |o| add(block[o]) }
    else
      merge(enum)
    end
  end

  def do_with_enum(enum, &block)
    if enum.respond_to?(:each_entry)
      enum.each_entry(&block) if block
    elsif enum.respond_to?(:each)
      enum.each(&block) if block
    else
      raise ArgumentError, "value must be enumerable"
    end
  end
  private :do_with_enum

  def initialize_dup(orig)
    super
    @hash = orig.instance_variable_get(:@hash).dup
  end

  if Kernel.instance_method(:initialize_clone).arity != 1
    def initialize_clone(orig, **options)
      super
      @hash = orig.instance_variable_get(:@hash).clone(**options)
    end
  else
    def initialize_clone(orig)
      super
      @hash = orig.instance_variable_get(:@hash).clone
    end
  end

  def freeze
    @hash.freeze
    super
  end

  def size
    @hash.size
  end
  alias length size

  def empty?
    @hash.empty?
  end

  def clear
    @hash.clear
    self
  end

  def to_a
    @hash.keys
  end

  def include?(o)
    @hash[o]
  end
  alias member? include?

  def superset?(set)
    case
    when set.instance_of?(self.class) && @hash.respond_to?(:>=)
      @hash >= set.instance_variable_get(:@hash)
    when set.is_a?(Set)
      size >= set.size && set.all? { |o| include?(o) }
    else
      raise ArgumentError, "value must be a set"
    end
  end
  alias >= superset?

  def proper_superset?(set)
    case
    when set.instance_of?(self.class) && @hash.respond_to?(:>)
      @hash > set.instance_variable_get(:@hash)
    when set.is_a?(Set)
      size > set.size && set.all? { |o| include?(o) }
    else
      raise ArgumentError, "value must be a set"
    end
  end
  alias > proper_superset?

  def subset?(set)
    case
    when set.instance_of?(self.class) && @hash.respond_to?(:<=)
      @hash <= set.instance_variable_get(:@hash)
    when set.is_a?(Set)
      size <= set.size && all? { |o| set.include?(o) }
    else
      raise ArgumentError, "value must be a set"
    end
  end
  alias <= subset?

  def proper_subset?(set)
    case
    when set.instance_of?(self.class) && @hash.respond_to?(:<)
      @hash < set.instance_variable_get(:@hash)
    when set.is_a?(Set)
      size < set.size && all? { |o| set.include?(o) }
    else
      raise ArgumentError, "value must be a set"
    end
  end
  alias < proper_subset?

  def <=>(set)
    return unless set.is_a?(Set)

    case size <=> set.size
    when -1 then -1 if proper_subset?(set)
    when +1 then +1 if proper_superset?(set)
    else 0 if self.==(set)
    end
  end

  def intersect?(set)
    case set
    when Set
      if size < set.size
        any? { |o| set.include?(o) }
      else
        set.any? { |o| include?(o) }
      end
    when Enumerable
      set.any? { |o| include?(o) }
    else
      raise ArgumentError, "value must be enumerable"
    end
  end

  def disjoint?(set)
    !intersect?(set)
  end

  def each(&block)
    block_given? or return enum_for(__method__) { size }
    @hash.each_key(&block)
    self
  end

  def add(o)
    @hash[o] = true
    self
  end
  alias << add

  def add?(o)
    add(o) unless include?(o)
  end

  def delete(o)
    @hash.delete(o)
    self
  end

  def delete?(o)
    delete(o) if include?(o)
  end

  def delete_if
    block_given? or return enum_for(__method__) { size }
    select { |o| yield o }.each { |o| @hash.delete(o) }
    self
  end

  def keep_if
    block_given? or return enum_for(__method__) { size }
    reject { |o| yield o }.each { |o| @hash.delete(o) }
    self
  end

  def reject!(&block)
    block_given? or return enum_for(__method__) { size }
    n = size
    delete_if(&block)
    self if size != n
  end

  def select!(&block)
    block_given? or return enum_for(__method__) { size }
    n = size
    keep_if(&block)
    self if size != n
  end

  alias filter! select!

  def merge(*enums, **_rest)
    enums.each do |enum|
      if enum.instance_of?(self.class)
        @hash.update(enum.instance_variable_get(:@hash))
      else
        do_with_enum(enum) { |o| add(o) }
      end
    end

    self
  end

  def subtract(enum)
    do_with_enum(enum) { |o| delete(o) }
    self
  end

  def |(enum)
    dup.merge(enum)
  end
  alias + |
  alias union |

  def -(enum)
    dup.subtract(enum)
  end
  alias difference -

  def &(enum)
    n = self.class.new
    if enum.is_a?(Set)
      if enum.size > size
        each { |o| n.add(o) if enum.include?(o) }
      else
        enum.each { |o| n.add(o) if include?(o) }
      end
    else
      do_with_enum(enum) { |o| n.add(o) if include?(o) }
    end
    n
  end
  alias intersection &

  def ^(enum)
    n = Set.new(enum)
    each { |o| n.add(o) unless n.delete?(o) }
    n
  end

  def ==(other)
    if self.equal?(other)
      true
    elsif other.instance_of?(self.class)
      @hash == other.instance_variable_get(:@hash)
    elsif other.is_a?(Set) && self.size == other.size
      other.all? { |o| @hash.include?(o) }
    else
      false
    end
  end

  def hash
    @hash.hash
  end

  def eql?(o)
    return false unless o.is_a?(Set)
    @hash.eql?(o.instance_variable_get(:@hash))
  end

  alias === include?

  def classify
    block_given? or return enum_for(__method__) { size }

    h = {}

    each { |i|
      (h[yield(i)] ||= self.class.new).add(i)
    }

    h
  end

  def divide(&func)
    func or return enum_for(__method__) { size }

    if func.arity == 2
      require 'tsort'

      class << dig = {}
        include TSort

        alias tsort_each_node each_key
        def tsort_each_child(node, &block)
          fetch(node).each(&block)
        end
      end

      each { |u|
        dig[u] = a = []
        each{ |v| func.call(u, v) and a << v }
      }

      set = Set.new()
      dig.each_strongly_connected_component { |css|
        set.add(self.class.new(css))
      }
      set
    else
      Set.new(classify(&func).values)
    end
  end
end

# sorted_set without rbtree dependency, vendored from
# https://github.com/ruby/set/blob/72f08c4/lib/set.rb#L731-L800
class CharacterSet::RubyFallback::SortedSet < CharacterSet::RubyFallback::Set
  def initialize(*args)
    @keys = nil
    super
  end

  def clear
    @keys = nil
    super
  end

  def add(o)
    @keys = nil
    super
  end
  alias << add

  def delete(o)
    @keys = nil
    @hash.delete(o)
    self
  end

  def delete_if
    block_given? or return enum_for(__method__) { size }
    n = @hash.size
    super
    @keys = nil if @hash.size != n
    self
  end

  def keep_if
    block_given? or return enum_for(__method__) { size }
    n = @hash.size
    super
    @keys = nil if @hash.size != n
    self
  end

  def merge(enum)
    @keys = nil
    super
  end

  def each(&block)
    block or return enum_for(__method__) { size }
    to_a.each(&block)
    self
  end

  def to_a
    (@keys = @hash.keys).sort! unless @keys
    @keys.dup
  end

  def freeze
    to_a
    super
  end
end

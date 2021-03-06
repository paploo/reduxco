module Reduxco
  # An immutable class that represents a referrence to a callable in a
  # CallableTable; this class is rarely used directly by clients.
  class CallableRef
    include Comparable

    # The minimum depth number allowed.
    MIN_DEPTH = 1

    # For string representations (typically used in debugging), this is
    # used as the separator between name and depth (if depth is given).
    STR_SEPARATOR = ':'

    # For string representations, what is the opening bracket string.
    STR_LEFT_BRACKET = '<'

    # For string representations, what is the opening bracket string.
    STR_RIGHT_BRACKET = '>'

    # [name] Typically the name is a symbol, but systems are free to use other
    #        objects as types are not coerced into other types at any point.
    #        If the name is a CallableRef, then this acts as a copy constructor.
    #
    # [depth] The depth is normally not given when used, can be specified for
    #         referencing specific shadowed callables when callables are flattend
    #         into a CallableTable; this is important for calls to super.
    def initialize(name, depth=nil)
      case name
      when self.class
        @name = name.name
        @depth = (depth && depth.to_i) || name.depth
      else
        @name = name
        @depth = depth && depth.to_i
      end

      raise IndexError, "Depth must be greater than zero", caller if depth && depth<MIN_DEPTH
    end

    # Returns the name of the refernce.
    attr_reader :name

    # Returns the depth of the reference, or nil if the reference is dynamic.
    attr_reader :depth

    # Is true valued when the reference will dynamically bind to an entry
    # in the CallableTable instead of to an entry at a specific depth.
    def dynamic?
      return depth.nil?
    end

    # Negation of dynamic?
    def static?
      return !dynamic?
    end

    # Returns a CallableRef with the same name, but one depth deeper.
    def succ
      if( dynamic? )
        raise RuntimeError, "Dynamic references cannot undergo relative movement."
      else
        self.class.new(name, depth.succ)
      end
    end
    alias_method :next, :succ

    # Returns a CallableRef with the same name, but one depth higher.
    def pred
      if( dynamic? )
        raise RuntimeError, "Dynamic references cannot undergo relative movement."
      else
        self.class.new(name, depth.pred)
      end
    end

    # Returns a unique hash value; useful resolving Hash entries.
    def hash
      @hash ||= self.to_a.hash
    end

    # Returns true if the passed ref is 
    #
    # This method raises an exception when compared to anything that does not
    # ducktype as a reference.
    def include?(other)
      other.name == self.name && (dynamic? ? true : other.depth == self.depth)
    end

    # Returns true if the refs are equivalent.
    def eql?(other)
      if( other.kind_of?(CallableRef) || (other.respond_to?(:name) && other.respond_to?(:depth)) )
        other.name == self.name && other.depth == self.depth
      else
        false
      end
    end
    alias_method :==, :eql?
    alias_method :===, :==

    # Returns the sort order of the reference.  This is primarily useed
    # for sorting references in CallableTable so that shadowed callables
    # are called properly.
    #
    # Static references are sorted by the following rule: For all sets of static
    # refs with equal names, sort by depth.  For all sets of static refs with
    # equal depths, only sort if the names are sortable.  This means that
    # there is no requirement for sort order to group by name or by depth, and
    # so no software should be written around an assumption of which comes first.
    #
    # Refuses to sort dynamic references, as they are not ordered compared to
    # static references.
    def <=>(other)
      if( dynamic? != other.dynamic? )
        nil
      else
        depth_eql = depth <=> other.depth
        (depth_eql==0 ? (name <=> other.name) : nil) || depth_eql
      end
    end

    # Returns an array form of this CallableReference.
    def to_a
      @array ||= [name, depth]
    end

    # Returns a hash form of this CallableReference.
    def to_h
      @hash ||= {name:name, depth:depth}
    end

    # Returns a human readable string form of this CallableReference.
    def to_s
      @string ||= STR_LEFT_BRACKET + self.to_a.compact.map {|prop| prop.to_s}.join(STR_SEPARATOR) + STR_RIGHT_BRACKET
    end

    # Returns a human readable string form of this CallableReference.
    def inspect
      to_s
    end

  end
end

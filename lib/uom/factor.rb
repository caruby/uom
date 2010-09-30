require 'extensional'
require 'uom/error'

module UOM
  # A Factor designates a Unit mangnitude along a dimensional axis.
  class Factor
    make_extensional do |hash, factor|
      hash[factor.label] = factor if factor.label
      hash[factor.abbreviation] = factor if factor.abbreviation
    end

    attr_reader :label, :abbreviation, :converter

    # Creates a Factor with the given label, abbreviations and conversion multiplier or block.
    # The multiplier is the amount of this factor in the base factor.
    # For example, KILO and MILLI are defined as:
    #   KILO = Factor.new(:kilo, :k, UNIT, 1000)
    #   MILLI = Factor.new(:milli, :m, UNIT, .001)
    # The +KILO+ definition is the same as:
    #   Factor.new(:kilo, :k, UNIT) { |unit| unit * 1000 }
    # This definition denotes that one kilo of a unit equals 1000 of the units.
    def initialize(label, abbreviation, base, multiplier=nil, &converter) # :yields: factor
      @label = label
      @abbreviation = abbreviation
      @base = base
      @converter = converter
      @converter ||= lambda { |n| n * multiplier } if multiplier
      # add this Factor to the extent
      Factor << self
    end

    # Returns the multiplier which converts this Factor into the given factor.
    def as(factor)
      if factor == self or (@converter.nil? and factor.converter.nil?) then
        1.0
      elsif @converter.nil? then
        1.0 / factor.as(self)
      elsif factor == @base then
        @converter.call(1)
      else
        self.as(@base) * @base.as(factor)
      end
    end

    def to_s
      label.to_s
    end

    def inspect
      content = "#{label}"
      content += ", #{abbreviation}" if abbreviation
      "#{self.class.name}@#{self.object_id}[#{content}]"
    end
  end
end
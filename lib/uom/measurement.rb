require 'forwardable'
require 'uom/error'
require 'uom/units'

module UOM
  # Measurement qualifies a quantity with a unit.
  class Measurement
    extend Forwardable

    attr_reader :quantity, :unit

    # Creates a new Measurement with the given quantity and unit label, e.g.:
    #   Measurement.new(:mg, 4) #=> 4 mg
    def initialize(unit, quantity)
      unit = UOM::Unit.for(unit) if Symbol === unit
      @quantity = quantity
      @unit = unit
      @unit_alias = unit unless unit == @unit.label
    end

    # numeric operators without an argument delegate to the quantity
    unary_operators = Numeric.instance_methods(false).map { |method| method.to_sym }.select { |method| Numeric.instance_method(method).arity.zero? } + [:to_i, :to_f]
    def_delegators(:@quantity, *unary_operators)

    # numeric operators with an argument apply to the quantity and account for a Measurement argument
    binary_operators = Numeric.instance_methods(false).map { |method| method.to_sym }.select { |method| Numeric.instance_method(method).arity == 1 } + [:+, :-, :*, :/, :==, :<=>, :eql?]
    binary_operators.each { |method| define_method(method) { |other| apply_to_quantity(method, other) } }
    [:+, :-, :==, :<=>, :div, :divmod, :quo, :eql?].each { |method| define_method(method) { |other| apply_to_quantity(method, other) } }

    def ==(other)
      return quantity == other unless Measurement === other
      unit == other.unit ? quantity == other.quantity : other.as(unit) == self
    end

    # Returns the product of this measurement and the other measurement or Numeric.
    # If other is a Measurement, then the returned Measurement Unit is the product of this
    # Measurement's unit and the other Measurement's unit.
    def *(other)
      compose(:*, other)
    end

    # Returns the quotient of this measurement and the other measurement or Numeric.
    # If other is a Measurement, then the returned Measurement Unit is the quotient of this
    # Measurement's unit and the other Measurement's unit.
    def /(other)
      compose(:/, other)
    end

    # Returns a new Measurement which expresses this measurement as the given unit.
    def as(unit)
      unit = UOM::Unit.for(unit.to_sym) if String === unit or Symbol === unit
      return self if @unit == unit
      Measurement.new(unit, @unit.as(quantity, unit))
    end

    def to_s
      unit = @unit_alias || unit.to_s(quantity)
      unit_s = unit.to_s
      suffix = quantity == 1 ? unit_s : unit_s.pluralize
      "#{quantity} #{suffix}"
    end

    private

    # Returns a new Measurement whose unit is this Measurement's unit and quantity is the
    # result of applying the given method to this Measurement's quantity and the other quantity.
    #
    # If other is a Measurement, then the operation argument is the other Measurement quantity, e.g.:
    #   Measurement.new(:g, 3).apply(Measurement.new(:mg, 2000), :div) #=> 1 gram
    def apply_to_quantity(method, other)
      other = other.as(unit).quantity if Measurement === other
      new_quantity = block_given? ? yield(to_f, other) : to_f.send(method, other)
      Measurement.new(unit, new_quantity)
    end

    # Returns the application of method to this measurement and the other measurement or Numeric.
    # If other is a Measurement, then the returned Measurement Unit is the composition of this
    # Measurement's unit and the other Measurement's unit.
    def compose(method, other)
     return apply_to_quantity(method, other) unless Measurement === other
     other = other.as(unit) if other.unit.axis == unit.axis
     new_quantity = quantity.zero? ? 0.0 : quantity.to_f.send(method, other.quantity)
     Measurement.new(unit.send(method, other.unit), new_quantity)
    end
  end
end

class String
  # Returns the Measurement parsed from this string, e.g.:
  #   "1 gm".to_measurement.unit #=> grams
  # If no unit is discernable from this string, then the default unit is used.
  #
  # Raises MeasurementError if there is no unit in either this string or the argument.
  def to_measurement(default_unit=nil)
    stripped = strip.delete(',')
    quantity_s = stripped[/[.\d]*/]
    quantity = quantity_s =~ /\./ ? quantity_s.to_f : quantity_s.to_i
    unit_s = stripped[quantity_s.length..-1] if quantity_s.length < length
    unit_s ||= default_unit.to_s if default_unit
    raise UOM::MeasurementError.new("Unit could not be determined from #{self}") if unit_s.nil?
    unit_s = unit_s.sub('/', '_per_')
    unit = UOM::Unit.for(unit_s.strip.to_sym)
    UOM::Measurement.new(unit, quantity)
  end

  # Returns this String as a unitized quantity.
  # If this is a numerical String, then it is returned as a Numeric.
  # Commas and a non-numeric prefix are removed if present.
  # Returns nil if this is not a measurement string.
  # If unit is given, then this method converts the measurement to the given unit.
  def to_measurement_quantity(unit=nil)
    # remove commas
    return to_measurement_quantity(delete(',')) if self[',']
    # extract the quantity portion
    quantity_s = self[/\d*\.?\d*/]
    return if quantity_s.nil? or quantity_s == '.'
    quantity = quantity_s['.'] ? quantity_s.to_f : quantity_s.to_i
    # extract the unit portion
    unit_s = self[/([[:alpha:]]+)(\s)?$/, 1]
    return quantity if unit_s.nil?
    # make the measurement
    msmt = "#{quantity} #{unit_s.downcase}".to_measurement
    # return the measurement quantity
    msmt = msmt.as(unit) if unit
    msmt.quantity
  end
end
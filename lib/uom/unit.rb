require 'set'
require 'active_support/inflector'
require 'extensional'
require 'uom/factors'
require 'uom/unit_factory'

module UOM
  # A Unit demarcates a standard magnitude on a Measurement Dimension.
  # A _base_ unit is an unscaled dimensional Unit, e.g. METER.
  # A _derived_ unit is composed of other units. The derived unit includes
  # a required dimensional _axis_ unit and an optional _scalar_ Factor,
  # e.g. the +millimeter+ unit is derived from the +meter+ axis and the
  # +milli+ scaling factor.
  #
  # The axis is orthogonal to the scalar. There is a distinct unit for each
  # axis and scalar. The base unit specifies the permissible scalar factors.
  class Unit
    @factory = UnitFactory.new

    # make the extension label=>Unit hash. this hash creates a new Unit on demand
    make_extensional(Hash.new { |hash, label| @factory.create(label) }) { |hash, unit| add_to_extent(hash, unit) }

    attr_reader :label, :scalar, :axis, :abbreviations, :dimension, :permissible_factors

    # Creates the Unit with the given label and parameters. The params include the following:
    # * a unit label followed by zero, one or more Symbol unit abbreviations
    # * one or more Dimension objects for a basic unit
    # * an optional axis Unit for a derived unit
    # * an optional scaling Factor for a derived unit
    # * an optional normalization multiplier which converts this unit to the axis
    # For example, a second is defined as:
    #   SECOND = Unit.new(:second, :sec, Dimension::TIME, MILLI, MICRO, NANO, PICO, FEMTO)
    # and a millisecond is defined as:
    #   Unit.new(MILLI, UOM::SECOND)
    # In most cases, a derived unit does not need to define a label or abbreviation
    # since these are inferred from the axis and factor.
    def initialize(*params, &converter)
      # this long initializer ensures that every unit is correct by construction
      # the first symbol is the label
      labels = params.select { |param| Symbol === param }
      @label = labels.first
      # a Numeric parameter indicates a conversion multiplier instead of a converter block
      multiplier = params.detect { |param| Numeric === param }
      if multiplier then
        # there can't be both a converter and a multiplier
        if converter then
          raise MeasurementError.new("Derived unit #{label} specifies both a conversion multiplier constant and a converter block")
        end
        # make the converter block from the multiplier
        converter = lambda { |n| n * multiplier }
      end
      # the optional Factor parameters are the permissible scaling factors
      factors = params.select { |param| Factor === param }.to_set
      # a convertable unit must have a unique factor
      if converter and factors.size > 1 then
        raise MeasurementError.new("Derived unit #{label} can have at most one scalar: #{axes.join(', ')}")
        @permissible_factors = []
      else
        @permissible_factors = factors
      end
      # the optional single Unit parameter is the axis for a derived unit
      axes = params.select { |param| Unit === param }
      raise MeasurementError.new("Unit #{label} can have at most one axis: #{axes.join(', ')}") if axes.size > 1
      @axis = axes.first
      # validate that a convertable unit has an axis; the converter argument is an axis quantity
      raise MeasurementError.new("Derived unit #{label} has a converter but does not have an axis unit") if @default_converter and @axis.nil?
      # the axis of an underived base unit is the unit itself
      @axis ||= self
      # validate that there is not a converter on self
      raise MeasurementError.new("Unit #{label} specifies a converter but not a conversion unit") unless converter.nil? if @axis == self
      # the default converter for a derived unit is identity
      converter ||= lambda { |n| n } unless @axis == self
      # the scalar is the first specified factor, or UNIT if there are multiple permissible factors
      @scalar = @permissible_factors.size == 1 ? @permissible_factors.to_a.first : UNIT
      # validate the scalar
      if @axis == self then
        #a derived unit cannot have a scalar factor
        raise MeasurementError.new("Base unit #{label} cannot have a scalar value - #{@scalar}") unless @scalar == UNIT
      elsif @scalar != UNIT and not @axis.permissible_factors.include?(@scalar) then
        # a derived unit scalar factor must be in the axis permissible factors
        raise MeasurementError.new("Derived unit #{label} scalar #{scalar} not a #{@axis} permissible factor #{@axis.permissible_factors.to_a.join(', ')}")
      end
      # if a scalar is defined, then adjust the converter
      scaled_converter = @scalar == UNIT ? converter : lambda { |n| @scalar.as(@axis.scalar) * converter.call(n) } 
      # add the axis converter to the converters hash
      @converters = {}
      @converters[@axis] = scaled_converter if converter
      # define the multiplier converter inverse
      @axis.add_converter(self) { |n| 1.0 / scaled_converter.call(1.0 / n) } unless @scalar.nil? and multiplier.nil?
      # make the label from the scalar and axis
      @label ||= create_label
      # validate label existence
      raise MeasurementError.new("Unit does not have a label") if self.label.nil?
      # validate label uniqueness
      if Unit.extent.association.has_key?(@label) then
        raise MeasurementError.new("Unit label #{@label} conflicts with existing unit #{Unit.extent.association[@label].inspect}")
      end
      # get the dimension
      dimensions = params.select { |param| Dimension === param }
      if dimensions.empty? then
        # a base unit must have a dimension
        raise MeasurementError.new("Base unit #{label} is missing a dimension") if @axis == self
        # a derived unit dimension is the axis dimension
        @dimension = axis.dimension
      elsif dimensions.size > 1 then
        # there can be at most one dimension
        raise MeasurementError.new("Unit #{label} can have at most one dimension")
      else
        # the sole specified dimension
        @dimension = dimensions.first
      end
      # the remaining symbols are abbreviations
      @abbreviations = labels.size < 2 ? [] : labels[1..-1]
      # validate abbreviation uniqueness
      conflict = @abbreviations.detect { |abbrev| Unit.extent.association.has_key?(abbrev) }
      raise MeasurementError.new("Unit label #{@label} conflicts with an existing unit") if conflict
      # add this Unit to the extent
      Unit << self
    end

    # Returns the Unit which is the basis for a derived unit.
    # If this unit's axis is the axis itself, then that is the basis.
    # Otherwise, the basis is this unit's axis basis. 
    def basis
      basic? ? self : axis.basis
    end

    # Returns whether this unit's axis is the unit itself.
    def basic?
      self == axis
    end

    def add_abbreviation(abbrev)
      @abbreviations << abbrev.to_sym
      Unit.extent.association[abbrev] = self
    end

    # Defines a conversion from this unit to the other unit.
    def add_converter(other, &converter)
      @converters[other] = converter
    end

    # Returns a division CompositeUnit consisting of this unit and the other unit, e.g.:
    #   (Unit.for(:gram) / Unit.for(:liter)).label #=> gram_per_liter
    def /(other)
      CompositeUnit.for(self, other, :/)
    end

    # Returns a product CompositeUnit consisting of this unit and the other unit, e.g.:
    #   (Unit.for(:pound) * Unit.for(:inch)).label #=> foot_pound
    def *(other)
      CompositeUnit.for(self, other, :*)
    end

    # Returns the given quantity converted from this Unit into the given unit.
    def as(quantity, unit)
      begin
        convert(quantity, unit)
      rescue MeasurementError => e
        raise MeasurementError.new("No conversion path from #{self} to #{unit} - #{e}")
      end
    end

    def to_s(quantity=nil)
      (quantity.nil? or quantity == 1) ? label.to_s : label.to_s.pluralize
    end

    def inspect
      "#{self.class.name}@#{self.object_id}[#{([label] + abbreviations).join(', ')}]"
    end

    protected

    def create_label
      "#{scalar.label}#{axis.label}".to_sym
    end

    private

    # Returns the given quantity converted from this Unit into the given unit.
    def convert(quantity, unit)
      return quantity if unit == self
      # if there is a converter to the target unit, then call it
      converter = @converters[unit]
      return converter.call(quantity) if converter
      # validate the target unit dimension
      raise MeasurementError.new("Cannot convert #{unit} dimension #{unit.dimension} to #{self} dimension #{@dimension}") unless @dimension == unit.dimension
      # convert via an axis pivot intermediary
      pivot = conversion_pivot(unit)
      pivot.as(self.as(quantity, pivot), unit)
    end

    def conversion_pivot(unit)
      # this unit's axis is the preferred pivot unless there is no separate axis
      return @axis unless self == @axis
      # out of luck if there is no axis intermediary
      raise MeasurementError.new("No converter from #{self} to #{unit}") if unit.axis == unit
      # convert via the other unit's axis intermediary
      unit.axis
    end

    # Utility method called by the Unit class after initialization to add this unit to the extent.
    def self.add_to_extent(hash, unit)
      hash[unit.label] = unit
      hash[unit.label.to_s.pluralize.to_sym] = unit
      unit.abbreviations.each do |abbrev|
        hash[abbrev] = unit
        hash[abbrev.to_s.pluralize.to_sym] = unit
      end
      unit
    end
  end
end

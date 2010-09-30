require 'extensional'

module UOM
  # Dimension enumerates the standard Unit dimensions. These consist of the seven physical International System of Units
  # SI base unit dimensions and an INFORMATION dimension for representing computer storage.
  class Dimension
    attr_accessor :label

    def initialize(label)
      @label = label
    end

    def to_s
      @label
    end
  end

  # A CompositeDimension combines dimensions with an operator.
  class CompositeDimension < Dimension
    make_extensional(Hash.new { |hash, spec| new(*spec) }) { |hash, dim| hash[dim.dimensions + [dim.operator]] = dim }

    attr_reader :dimensions, :operator

    # Creates a CompositeDimension from the given dimensions and operator symbol
    def initialize(dimensions, operator)
      @dimensions = dimensions
      @operator = operator
      super(create_label)
      # add to the extent
      CompositeDimension << self
    end

    private

    def create_label
      @dimensions.join("_#{@operator}_")
    end
  end
end
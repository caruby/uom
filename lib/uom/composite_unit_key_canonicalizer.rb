require 'uom/composite_unit'

module UOM
   # A CompositeUnitKeyCanonicalizer creates a standard key for the CompositeUnit extent.
  class CompositeUnitKeyCanonicalizer
    def match(hash, u1, u2, operator)
      spec = canonicalize(u1, u2, operator)
      hash[spec] ||= new(*spec)
    end

    # Returns the canonical form of the given units u1 and u2 and operator +:*+ or +:/+ as an array consisting
    # of a CompositeUnit, non-composite Unit and operator, e.g.:
    #   canonicalize(METER, SECOND * SECOND, :*) #=> [METER * SECOND, SECOND, :*]
    #   canonicalize(METER, SECOND / SECOND, :*) #=> [METER * SECOND, SECOND, :/]
    #   canonicalize(METER, SECOND * SECOND, :/) #=> [METER / SECOND, SECOND, :/]
    #   canonicalize(METER, SECOND / SECOND, :/) #=> [METER / SECOND, SECOND, :*]
    #
    # The locator block given to this method matches a CompositeUnit with arguments u11, u12 and op1.
    # 
    # See also canonicalize_operators.
    def canonicalize(u1, u2, operator, &locator) # :yields: u11, u12, op1
      # nothing to do if u2 is already a non-composite unit
      return u1, u2, operator unless CompositeUnit === u2
      # canonicalize u2
      cu21, cu22, cop2 = canonicalize(u2.axes.first, u2.axes.last, u2.operator, &locator)
      # redistribute u1 with the canonicalized u2 axes cu21 and cu22 using the redistributed operators rop1 and rop2
      rop1, rop2 = redistribute_operators(operator, cop2)
      # yield canonicalize(u1, cu21, rop1, &locator)
      # the maximally reduced canonical form
      return u1.send(rop1, cu21), cu22, rop2
    end

    # Returns the operators to apply to a canonical form according to the rules:
    #   x * (y * z) = (x * y) * z
    #   x * (y / z) = (x * y) / z
    #   x / (y * z) = (x / y) / z
    #   x / (y / z) = (x / y) * z
    # i.e.:
    #   redistribute_operators(:*, :*) #=> [:*, :*]
    #   redistribute_operators(:*, :/) #=> [:*, :/]
    #   redistribute_operators(:/, :*) #=> [:/, :/]
    #   redistribute_operators(:/, :/) #=> [:/, :*]
    def redistribute_operators(operator, other)
      # not as obscure as it looks: if operator is * then there is no change to the operators since * is associative, i.e.:
      #   x * (y * z) = (x * y) * z
      #   x * (y / z) = (x * y) / z
      # otherwise, operator is /. in that case, apply the rules:
      #   x / (y * z) = (x / y) / z
      #   x / (y / z) = (x / y) * z
      operator == :* ? [operator, other] : (other == :* ? [:/, :/] : [:/, :*])
    end
  end
end
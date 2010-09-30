require 'uom/factor'

module UOM
  # the metric scaling factors
  UNIT = Factor.new(nil, nil, nil) # the anonymous unit factor
  DECI = Factor.new(:deci, :d, UNIT, 0.1)
  CENTI = Factor.new(:centi, :c, UNIT, 0.01)
  MILLI = Factor.new(:milli, :m, UNIT, 0.001)
  MICRO = Factor.new(:micro, :u, MILLI, 0.001)
  NANO = Factor.new(:nano, :n, MICRO, 0.001)
  PICO = Factor.new(:pico, :p, NANO, 0.001)
  FEMTO = Factor.new(:femto, :f, PICO, 0.001)
  ATTO = Factor.new(:atto, :a, FEMTO, 0.001)
  ZEPTO = Factor.new(:zepto, :z, ATTO, 0.001)
  YOCTO = Factor.new(:yocto, :y, ZEPTO, 0.001)
  DECA = Factor.new(:deca, :da, UNIT, 10)
  HECTO = Factor.new(:hecto, :h, UNIT, 100)
  KILO = Factor.new(:kilo, :k, UNIT, 1000)
  MEGA = Factor.new(:mega, :M, KILO, 1000)
  GIGA = Factor.new(:giga, :G, MEGA, 1000)
  TERA = Factor.new(:tera, :T, GIGA, 1000)
  PETA = Factor.new(:peta, :P, TERA, 1000)
  EXA = Factor.new(:exa, :E, PETA, 1000)
  ZETTA = Factor.new(:zetta, :Z, EXA, 1000)
  YOTTA = Factor.new(:yotta, :Y, ZETTA, 1000)

  # All metric factors.
  METRIC_FACTORS = [YOTTA, ZETTA, EXA, TERA, GIGA, MEGA, KILO, HECTO, DECA, DECI, CENTI, MILLI, MICRO, NANO, PICO, FEMTO, ATTO, ZEPTO, YOCTO]

  # Factors commonly used in electronics
  ELECTRONIC_FACTORS = [MILLI, MICRO, NANO, PICO, TERA, GIGA, MEGA, KILO]
end
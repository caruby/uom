require 'uom/dimensions'
require 'uom/factors'
require 'uom/unit'
require 'uom/composite_unit'

module UOM
  ## STANDARD UNITS ##

  # the standard units for each dimension
  METER = Unit.new(:meter, :m, LENGTH, *METRIC_FACTORS)
  GRAM = Unit.new(:gram, :gm, :g, MASS, *METRIC_FACTORS)
  SECOND = Unit.new(:second, :sec, :s, TIME, MILLI, MICRO, NANO, PICO, FEMTO)
  KELVIN = Unit.new(:kelvin, :K, TEMPERATURE)
  CANDELA = Unit.new(:candela, :cd, INTENSITY)
  AMPERE = Unit.new(:ampere, :A, CURRENT, *ELECTRONIC_FACTORS)
  MOLE = Unit.new(:mole, :mol, MASS)
  BYTE = Unit.new(:byte, :Byte, :B, :b, INFORMATION) # Scaled byte units, e.g KByte, are defined below

  ## SCALED UNITS ##
  # Just a few common metric units; units are typically referred to by label rather than a constant,
  # e.g. <tt>Unit.for(:millimeter)</tt>
  MILLIMETER = Unit.for(:millimeter)
  CENTIMETER = Unit.for(:centimeter)
  DECIMETER = Unit.for(:decimeter)
  MICROGRAM = Unit.for(:microgram)
  MILLIGRAM = Unit.for(:milligram)
  KILOGRAM = Unit.for(:kilogram)

  # The BYTE scale is a base two axis multiplier rather than a metric scalar multipler.
  # TODO - express these with base-2 factors?
  KILOBYTE = Unit.new(:kilobyte, :KByte, :KB, BYTE, 1024)
  MEGABYTE = Unit.new(:megabyte, :MByte, :MB, KILOBYTE, 1024)
  GIGABYTE = Unit.new(:gigabyte, :GByte, :GB, MEGABYTE, 1024)
  TERABYTE = Unit.new(:terabyte, :TByte, :TB, GIGABYTE, 1024)
  PETABYTE = Unit.new(:petabyte, :PByte, :PB, TERABYTE, 1024)

  ## DERIVED UNITS ##

  # astronomical distances
  ANGSTROM = Unit.new(:angstrom, :a, METER, 10000000000)
  AU = Unit.new(:astronomical_unit, :AU, METER, 149597870691)
  LIGHT_YEAR = Unit.new(:light_year, :ly, METER, 9460730472580800)

  # temperature with inverse converters
  CELSIUS = Unit.new(:celsius, :C, KELVIN) { |celsius| celsius - 273.15 }
  KELVIN.add_converter(CELSIUS) { |kelvin| kelvin + 273.15 }
  FARENHEIT = Unit.new(:farenheit, :F, CELSIUS) { |farenheit| (farenheit - 32) * (5 / 9) }
  CELSIUS.add_converter(FARENHEIT) { |celsius| (celsius + 32) * (9 / 5) }
  # mark temperatures as uncountable for the parser
  ActiveSupport::Inflector.inflections { |inflect| inflect.uncountable('celsius', 'kelvin', 'farenheit') }

  # time
  MINUTE = Unit.new(:minute, :min, SECOND, 60)
  HOUR = Unit.new(:hour, :hr, MINUTE, 60)
  DAY = Unit.new(:day, HOUR, 24)
  
  # information
  BIT = Unit.new(:bit, BYTE, 1.0 / 8)

  # US Customary length units
  INCH = Unit.new(:inch, :in, METER, 0.0254)
  FOOT = Unit.new(:foot, :ft, INCH, 12)
  YARD = Unit.new(:yard, :yd, FOOT, 3)
  MILE = Unit.new(:mile, :mi, FOOT, 5280)

  # US Customary weight units
  OUNCE = Unit.new(:ounce, :oz, GRAM, 28.34952)
  POUND = Unit.new(:pound, :lb, OUNCE, 16)
  TON = Unit.new(:ton, POUND, 2000)
  GRAIN = Unit.new(:grain, :gr, POUND, 1.0 / 7000)
  DRAM = Unit.new(:dram, :dr, OUNCE, 1.0 / 16)

  # Metric composite units
  LITER = Unit.new(:liter, :l, :L, DECIMETER * DECIMETER * DECIMETER, *METRIC_FACTORS)
  MILLILITER = Unit.for(:milliliter)
  JOULE = Unit.new(:joule, :J, (KILOGRAM * (METER * METER)) / (SECOND * SECOND), *ELECTRONIC_FACTORS)
  ERG = Unit.new(:erg, (GRAM * (CENTIMETER * CENTIMETER)) / (SECOND * SECOND), *ELECTRONIC_FACTORS)
  DYNE = Unit.new(:dyne, :dyn, (GRAM * CENTIMETER) / (SECOND * SECOND), *ELECTRONIC_FACTORS)
  NEWTON = Unit.new(:newton, :N, (KILOGRAM * METER) / (SECOND * SECOND), *SIMPLE_FACTORS)
  BAR = Unit.new(:bar, NEWTON, 0.00001, *SIMPLE_FACTORS)
  PASCAL = Unit.new(:pascal, :Pa, NEWTON / (METER * METER), *SIMPLE_FACTORS)
  ATMOSPHERE = Unit.new(:atmosphere, :atm, PASCAL, 0.101325, *SIMPLE_FACTORS)
  TORR = Unit.new(:torr, ATMOSPHERE, 1.0 / 760, *SIMPLE_FACTORS)
  BARYE = Unit.new(:barye, :Ba, GRAM / (CENTIMETER * (SECOND * SECOND)), *ELECTRONIC_FACTORS)
  POISE = Unit.new(:poise, :P, GRAM / (CENTIMETER * SECOND), KILO, MILLI, MICRO, NANO, PICO)
  COULOMB = Unit.new(:coulomb, AMPERE / SECOND, *ELECTRONIC_FACTORS) # C abbreviation is taken by CENTIGRADE
  VOLT = Unit.new(:volt, :V, JOULE / COULOMB, *ELECTRONIC_FACTORS)
  FARAD = Unit.new(:farad, COULOMB / VOLT, *ELECTRONIC_FACTORS) # F abbreviation is taken by FARENHEIT
  WEBER = Unit.new(:weber, :Wb, VOLT * SECOND, *ELECTRONIC_FACTORS)
  HENRY = Unit.new(:henry, :H, WEBER / AMPERE, METRIC_FACTORS)
  MAXWELL = Unit.new(:maxwell, :Mx, WEBER, 1.0 / 10 ** 8, METRIC_FACTORS)
  GAUSS = Unit.new(:gauss, :G, MAXWELL / (CENTIMETER * CENTIMETER), METRIC_FACTORS)
  # mark gauss as irregular for the parser
  ActiveSupport::Inflector.inflections { |inflect| inflect.irregular('gauss', 'gausses') }
  TESLA = Unit.new(:tesla, :T, WEBER / (METER * METER), DECI, CENTI, MILLI, MICRO, NANO, PICO)

  # The speed of light in a vacuum in cm/sec.
  C = 29979245800

  OHM = Unit.new(:ohm, SECOND / CENTIMETER, 10 ** 9 / C)

  # US Customary liquid volume units
  FLUID_OUNCE = Unit.new(:fluid_ounce, :fl_oz, MILLILITER, 29.57353)
  TBSP = Unit.new(:tablespoon, :tbsp, FLUID_OUNCE, 2)
  TSP = Unit.new(:teaspoon, :tsp, TBSP, 1.0 / 3)
  CUP = Unit.new(:cup, :cp, FLUID_OUNCE, 8)
  PINT = Unit.new(:pint, :pt, CUP, 2)
  QUART = Unit.new(:quart, :qt, PINT, 2)
  GALLON = Unit.new(:gallon, :gal, QUART, 4)

  # US Customary dry volume units
  DRY_PINT = Unit.new(:dry_pint, :dry_pt, LITER) { |liter| liter / 0.5506105 }
  DRY_QUART = Unit.new(:dry_quart, :dry_qt, DRY_PINT, 2)
  DRY_GALLON = Unit.new(:dry_gallon, :dry_gal, DRY_QUART, 4)
  PECK = Unit.new(:peck, :pk, DRY_GALLON, 2)
  BUSHEL = Unit.new(:bushel, :bu, PECK, 4)
  
  # Pressure alias
  PSI = Unit.for(:pounds_per_square_inch).add_abbreviation(:psi)
end

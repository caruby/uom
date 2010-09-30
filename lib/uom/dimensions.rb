require 'uom/dimension'

module UOM
  LENGTH = Dimension.new(:length)
  MASS = Dimension.new(:mass)
  TEMPERATURE = Dimension.new(:temperature)
  TIME = Dimension.new(:time)
  ENERGY = Dimension.new(:energy)
  INTENSITY = Dimension.new(:intensity)
  CURRENT = Dimension.new(:current)
  INFORMATION = Dimension.new(:information)
end
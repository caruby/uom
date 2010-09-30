$:.unshift 'lib'
$:.unshift '../extensional/lib'

require "test/unit"
require 'uom/units'
require 'uom/composite_unit_key_canonicalizer'

class CompositeUnitKeyCanonicalizerTest < Test::Unit::TestCase
  def setup
    @canonicalizer = UOM::CompositeUnitKeyCanonicalizer.new
  end

  def test_product_product
    standard = [UOM::GRAM * UOM::METER, UOM::SECOND, :*]
    variant =  @canonicalizer.canonicalize(UOM::GRAM, UOM::METER * UOM::SECOND, :*)
    assert_equal(standard, variant, "Canonicalization of x * (y * z) incorrect")
  end

  def test_product_quotient
    standard = [UOM::GRAM * UOM::METER, UOM::SECOND, :/]
    variant =  @canonicalizer.canonicalize(UOM::GRAM, UOM::METER / UOM::SECOND, :*)
    assert_equal(standard, variant, "Canonicalization of x * (y / z) incorrect")
  end

  def test_quotient_product
    standard = [UOM::GRAM / UOM::METER, UOM::SECOND, :/]
    variant =  @canonicalizer.canonicalize(UOM::GRAM, UOM::METER * UOM::SECOND, :/)
    assert_equal(standard, variant, "Canonicalization of x / (y * z) incorrect")
  end

  def test_quotient_quotient
    standard = [UOM::GRAM / UOM::METER, UOM::SECOND, :*]
    variant =  @canonicalizer.canonicalize(UOM::GRAM, UOM::METER / UOM::SECOND, :/)
    assert_equal(standard, variant, "Canonicalization of x / (y / z) incorrect")
  end

  def test_joule
    joule = UOM::JOULE.axis
    assert_equal(((UOM::KILOGRAM * UOM::METER) * UOM::METER) / UOM::SECOND, joule.axes.first, "Joule canonicalization first axis incorrect")
    assert_equal(UOM::SECOND, joule.axes.last, "Joule canonicalization second axis incorrect")
    assert_equal(:/, joule.operator, "Joule canonicalization operator incorrect")
  end
end

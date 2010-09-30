$:.unshift 'lib'
$:.unshift '../extensional/lib'

require "test/unit"
require 'uom/units'

class CompositeUnitTest < Test::Unit::TestCase
  def test_square
    square_meter = UOM::METER * UOM::METER
    assert_equal(:square_meter, square_meter.label, "Square meter label incorrect")
    assert_equal([UOM::METER, UOM::METER], square_meter.axes, "Square meter axes incorrect: #{square_meter.axes.join(', ')}")
    assert_same(square_meter, UOM::Unit.for(:square_meter), "Square meter lookup by label incorrect")
    assert_same(square_meter, UOM::METER * UOM::METER, "Square meter product inconsistent")
  end

  def test_cube
    cubic_meter = UOM::METER * UOM::METER * UOM::METER
    assert_equal(:cubic_meter, cubic_meter.label, "Cubic meter label incorrect")
    assert_equal([UOM::METER * UOM::METER, UOM::METER], cubic_meter.axes, "Cubic meter axes incorrect: #{cubic_meter.axes.join(', ')}")
    assert_same(cubic_meter, UOM::Unit.for(:cubic_meter), "Cubic meter lookup by label incorrect")
    assert_same(cubic_meter, UOM::METER * UOM::METER * UOM::METER, "Cubic meter product inconsistent")
  end

  def test_basic_scale_low_to_high
    roundtrip = UOM::MILLIMETER.as(UOM::METER.as(4, UOM::MILLIMETER), UOM::METER)
    assert_in_delta(4.0, roundtrip, 0.0000000001, "Scale conversion incorrect")
  end

  def test_idempotent_product_conversion
    product = UOM::MILLIGRAM * UOM::LITER
    assert_equal(:milligram_liter, product.label, "Composite product label incorrect")
    other = UOM::GRAM * UOM::MILLILITER
    roundtrip = other.as(product.as(4, other), product)
    assert_in_delta(4.0, roundtrip, 0.0000000001, "Idempotent roduct conversion milligram_liter => gram_milliter incorrect: #{roundtrip}")
  end

  def test_idempotent_quotient_conversion
    quotient = UOM::GRAM / UOM::LITER
    assert_equal(:grams_per_liter, quotient.label, "Composite divide label incorrect")
    other = UOM::MILLIGRAM / UOM::MILLILITER
    roundtrip = other.as(quotient.as(4, other), quotient)
    assert_in_delta(4.0, roundtrip, 0.0000000001, "Idempotent quotient conversion grams_per_liter => milligrams_per_milliliter incorrect: #{roundtrip}")
  end

  def test_basic_volume_conversion
    roundtrip = UOM::QUART.as(UOM::LITER.as(4, UOM::QUART), UOM::LITER)
    assert_in_delta(4.0, roundtrip, 0.000000001, "Quotient volume liter => quart => liter incorrect: #{roundtrip}")
  end

  def test_volume_scale_conversion
    roundtrip = UOM::LITER.as(UOM::MILLILITER.as(4, UOM::LITER), UOM::MILLILITER)
    assert_in_delta(4.0, roundtrip, 0.0000000001, "Quotient volume millliter => liter => liter incorrect: #{roundtrip}")
  end

  def test_scaled_axis_concentration_conversion
    roundtrip = UOM::CUP.as(UOM::MILLILITER.as(4, UOM::CUP), UOM::MILLILITER)
    assert_in_delta(4.0, roundtrip, 0.0000000001, "Quotient conversion milligrams_per_milliliter => dram_per_cup incorrect: #{roundtrip}")
  end

  def test_measurement_system_quotient_conversion
    quotient = UOM::MILLIGRAM / UOM::MILLILITER
    other = UOM::DRAM / UOM::CUP
    roundtrip = other.as(quotient.as(4, other), quotient)
    assert_in_delta(4.0, roundtrip, 0.0000000001, "Quotient conversion milligrams_per_milliliter => dram_per_cup incorrect: #{roundtrip}")
  end

  def test_psi
    assert_not_nil(UOM::Unit.for(:psi), "PSI abbreviation missing")
  end
end

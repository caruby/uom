$:.unshift 'lib'
$:.unshift '../extensional/lib'

require "test/unit"
require 'uom'

# Not to be confused with Test::Unit, UnitTest tests Unit.
class UnitTest < Test::Unit::TestCase
  include UOM

  private

  # joule-pecks per erg-gauss
  JPEG = Unit.for((JOULE * PECK) / (ERG * GAUSS)).add_abbreviation(:jpeg)

  public

  def test_scale_high_to_low
    assert_equal(4000, METER.as(4, MILLIMETER).to_f, "Scale conversion incorrect")
  end

  def test_scale_low_to_high
    assert_equal(0.04, CENTIMETER.as(4, METER).to_f, "Scale conversion incorrect")
  end

  def test_byte
    assert_equal(4 * 1024 * 1024, GIGABYTE.as(4, KILOBYTE).to_f, "Scale conversion incorrect")
  end

  def test_axis_conversion
    round_trip = INCH.as(MILLIMETER.as(4, INCH), MILLIMETER)
    assert_in_delta(4.0, round_trip.to_f, 0.000000001, "Unit conversion incorrect")
  end

  def test_basic_to_derived
    round_trip = DRAM.as(GRAM.as(4, DRAM), GRAM)
    assert_in_delta(4.0, round_trip.to_f, 0.000000001, "Unit conversion incorrect")
  end

  def test_new_unit
    jpeg = Measurement.new(:jpeg, 4)
    expected = Measurement.new(:joule_peck, 4) / Measurement.new(:erg_gauss, 1)
    assert_equal(expected, jpeg, "New unit incorrect")
  end
end

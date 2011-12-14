require File.dirname(__FILE__) + '/../helper'
require "test/unit"
require 'uom'

class UOMTest < Test::Unit::TestCase
  include UOM

  def test_alias
    assert_equal(:gram, Measurement.new(:g, 1).unit.label, "Gram alias not recognized")
  end

  def test_scale
    assert_equal(:milligram, Measurement.new(:mg, 1).unit.label, "Milligram not recognized")
  end

  def test_conversion
    round_trip = Measurement.new(MILLIMETER, 4).as(INCH).as(MILLIMETER)
    assert_in_delta(4.0, round_trip.to_f, 0.0000001, "Unit conversion incorrect")
  end

  def test_product
    assert_equal(4, Measurement.new(:meter, 2) * 2, "Numeric product incorrect")
    actual =  Measurement.new(:meter, 2) * Measurement.new(:millimeter, 2000)
    assert_equal(Measurement.new(:square_meter, 4), actual, "Measurement product incorrect: #{actual}")
  end

  def test_quotient
    assert_equal(2, Measurement.new(:gram, 4) / 2, "Numeric quotient incorrect")
    actual =  Measurement.new(:milligram, 4) / Measurement.new(:milliliter, 2)
    assert_equal(Measurement.new(:milligram_per_milliliter, 2), actual, "Measurement quotient incorrect: #{actual}")
  end

  def test_equal
    assert_equal(1, Measurement.new(:gram, 1), "Numeric equality not supported")
    assert_equal(Measurement.new(:gram, 1), Measurement.new(:gram, 1), "Equality not reflexive")
    assert_equal(Measurement.new(:g, 1), Measurement.new(:mg, 1000), "Equality does not account for factor conversion")
  end

  def test_concentration_alias
    assert_equal(:grams_per_liter, Measurement.new(:g_per_l, 1).unit.label,"Concentration alias not recognized")
  end

  def test_concentration_conversion
    assert_equal(0.004, Measurement.new(:mg_per_l, 4).as(:ug_per_ul).quantity, "Concentration conversion incorrect")
  end

  def test_idempotent_quotient_conversion
    quotient = GRAM / LITER
    assert_equal(:grams_per_liter, quotient.label, "Composite divide label incorrect")
    other = MILLIGRAM / MILLILITER
    roundtrip = Measurement.new(quotient, 4).as(other).as(quotient)
    assert_equal(Measurement.new(other, 4.0), roundtrip, "Idempotent quotient conversion 4 grams_per_liter => milligrams_per_milliliter incorrect: #{roundtrip}")
  end
  
  def test_parse_unknown_factor
    assert_raises(UOM::MeasurementError, "'1 unknown' didn't raise a measurement error") { "1 unknown".to_measurement }
  end

  def test_parse_known_factors
    assert_equal(Measurement.new(:gram, 1), "1g".to_measurement, "'1g' not parsed")
    assert_equal(Measurement.new(:gram, 1), "1 g".to_measurement, "'1 g' not parsed")
    assert_equal(Measurement.new(:gram, 1), "1 gm".to_measurement, "'1 gm' not parsed")
    assert_equal(Measurement.new(:gram, 1), "1 gram".to_measurement, "gram not parsed")
    assert_equal(Measurement.new(:gram, 4), "4 grams".to_measurement, "grams not parsed")
    assert_equal(:micrograms_per_microliter, ".2 ug_per_ul".to_measurement.unit.label, "ug_per_ul not parsed")
    assert_equal(:milligrams_per_liter, ".2 mg/l".to_measurement.unit.label, "ug/ul not parsed")
    assert_equal(:milligram, "2".to_measurement(:milligram).unit.label, "Default not used")
  end

  def test_print
    assert_equal("1 gram", Measurement.new(:gram, 1).to_s, "Measurement String incorrect")
    assert_equal("2 grams", Measurement.new(:gram, 2).to_s, "Measurement String incorrect")
  end
end
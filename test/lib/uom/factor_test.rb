require File.dirname(__FILE__) + '/../helper'
require "test/unit"
require 'uom'

class FactorTest < Test::Unit::TestCase
  def test_small_to_unit
    assert_equal(1000, UOM::MILLI.as(UOM::UNIT), "milli => unit incorrect")
  end

  def test_unit_to_large
    assert_equal(0.1, UOM::UNIT.as(UOM::DECA), "unit => deca incorrect")
  end

  def test_large_to_small
    assert_equal(0.000000001, UOM::KILO.as(UOM::MICRO), "kilo => micro incorrect")
  end

  def test_small_to_large
    assert_equal(1000000, UOM::MILLI.as(UOM::KILO), "milli => kilo incorrect")
  end
end

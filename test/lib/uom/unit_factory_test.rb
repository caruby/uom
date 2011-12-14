require File.dirname(__FILE__) + '/../helper'
require "test/unit"

# JRuby SyncEnumerator moved from generator to REXML in JRuby 1.5
require 'rexml/document'

require 'uom/units'

class UnitFactoryTest < Test::Unit::TestCase
  def setup
    @factory = UOM::UnitFactory.new
  end

  def test_gram
    assert_equal(:gram, @factory.create('gram').label, "gram not recognized")
    assert_equal(:gram, @factory.create('gm').label, "gm not recognized")
    assert_equal(:gram, @factory.create('g').label, "g not recognized")
  end

  def test_milligram
    assert_equal(:milligram, @factory.create('milligram').label, "milligram not recognized")
    assert_equal(:milligram, @factory.create('mg').label, "mg not recognized")
  end

  def test_kiloliter
    assert_equal(:kiloliter, @factory.create('kiloliter').label, "kiloliter not recognized")
    assert_equal(:kiloliter, @factory.create('kl').label, "kl not recognized")
  end

  def test_product
    assert_equal(:foot_pound, @factory.create('foot_pound').label, "foot_pound not recognized")
    assert_equal(:foot_pound, @factory.create('ft_lb').label, "ft_lb not recognized")
  end

  def test_quotient
    assert_equal(:milligrams_per_milliliter, @factory.create('milligrams_per_milliliter').label, "milligrams_per_milliliter not recognized")
    assert_equal(:milligrams_per_milliliter, @factory.create('mg_per_ml').label, "mg_per_ml not recognized")
  end

  def test_square
    assert_equal(:square_inch, @factory.create('square_inch').label, "square_inch not recognized")
    assert_equal(:square_inch, @factory.create('sq_in').label, "sq_in not recognized")
  end

  def test_cubic
    assert_equal(:cubic_inch, @factory.create('cubic_inch').label, "cubic_inch not recognized")
    assert_equal(:cubic_inch, @factory.create('cu_in').label, "cu_in not recognized")
  end

  def test_psi
    assert_equal(:pounds_per_inches_per_inch, @factory.create('pounds_per_square_inch').label, "pounds_per_square_inch not recognized")
    assert_equal(:pounds_per_inches_per_inch, @factory.create('lb_per_sq_in').label, "lb_per_sq_in not recognized")
  end

  def test_energy
    assert_equal(:kilojoule, @factory.create('kilojoule').label, "joule not recognized")
    assert_equal(:kilojoule, @factory.create('kJ').label, "kJ not recognized")
  end

  def test_time
    assert_equal(:nanosecond, @factory.create('nanosecond').label, "nanosecond not recognized")
    assert_equal(:nanosecond, @factory.create('nsec').label, "nsec not recognized")
  end

  def test_temperature
    assert_equal(:celsius, @factory.create('celsius').label, "celsius not recognized")
    assert_equal(:celsius, @factory.create('C').label, "C not recognized")
    assert_equal(:farenheit, @factory.create('farenheit').label, "farenheit not recognized")
    assert_equal(:farenheit, @factory.create('F').label, "F not recognized")
  end

  def test_kilobyte
    assert_equal(:kilobyte, @factory.create('kilobyte').label, "kilobyte not recognized")
    assert_equal(:kilobyte, @factory.create('kByte').label, "KByte not recognized")
    assert_equal(:kilobyte, @factory.create('kb').label, "KB not recognized")
  end

  # Tests parsing all possible combinations of labels, abbrevs and factors.
  def test_all
    units = File.open(ALL_UNITS, 'r').map { |line| line.chomp }
    REXML::SyncEnumerator.new(units, generate_all_units).each do |expected, actual|
      assert_equal(expected, actual, "Generated units differs from documented units")
    end
  end

  def verify_create(label, axis, scalar=nil)
    actual = @factory.create(label)
    assert_same(axis.basis, actual.basis, "Unit with label '#{label}' basis is incorrect")
    unless actual.scalar == UOM::UNIT and scalar.nil? then
      assert_same(scalar, actual.scalar, "Unit '#{label}' scalar factor incorrect")
    end
  end
  
  private
  
  ALL_UNITS = File.expand_path('units.txt', File.dirname(__FILE__) + '/../../../doc')

  def generate_all_units
    basic = UOM::Unit.select do |unit|
      unit.scalar == UOM::UNIT and not UOM::CompositeUnit === unit
    end
    all = basic.map do |unit|
      labels = []
      [UOM::UNIT].concat(unit.permissible_factors.to_a).each do |factor|
        labels << label = "#{factor}#{unit}"
        verify_create(label, unit, factor)
        unless label == label.pluralize then
          verify_create(label.pluralize, unit, factor)
          labels << label.pluralize
        end
        unit.abbreviations.each do |abbrev|
          labels << label = "#{factor.abbreviation}#{abbrev}"
          verify_create(label, unit, factor)
          abbrev_s = abbrev.to_s
          unless abbrev_s.length < 2 then
            plural = label + 's'
            verify_create(plural, unit, factor)
            labels << plural
          end
        end
      end
      labels.join(', ')
    end
    # combine byte measures
    byte, std = all.partition { |line| line =~ /byte/ }
    bh = {}
    byte.each do |line|
      key = /^(.*byte),.*/.match(line).captures.first.to_sym
     bh[key] = line.chomp
    end
    std << [:byte, :kilobyte, :megabyte, :gigabyte, :terabyte, :petabyte].map { |k| bh[k] }.join(', ')
    std.sort
  end
end

require 'set'
require 'active_support/inflector'
require 'uom/error'
require 'uom/units'

module UOM
  # A UnitFactory creates Unit instances.
  class UnitFactory
    LABEL_EXPONENT_HASH = {:square=>2, :sq=>2, :cubic=>3, :cu=>3}

    # Returns the unit with the given label. Creates a new unit if necessary.
    #
    # Raises MeasurementError if the unit could not be created.
    def create(label)
      create_atomic(label.to_s) or create_composite(label.to_s) or raise MeasurementError.new("Unit '#{label}' not found")
    end

    private

    def unit_for(label)
      # the label => Unit hash of known units
      @label_unit_hash ||= Unit.extent.association
      # test whether there is an association before accessing it by label, since the extent hash
      # has a hash factory that creates a Unit on demand, which is not desirable here
      @label_unit_hash[label.to_sym] if @label_unit_hash.has_key?(label.to_sym)
    end

    def create_atomic(label)
      scalar, axis = partition_atomic_label(label)
      return if axis.nil?
      label = "#{scalar}#{axis}".to_sym
      unit_for(label) or Unit.new(label, scalar, axis)
    end

    def create_composite(label)
      create_division(label) or create_product(label)
    end

    def create_division(str)
      labels = str.split('_per_')
      return if labels.size < 2
      units = labels.map { |label| create(label) or raise MeasurementError.new("Unit '#{label}' not found in #{str}") }
      std_label = units.join('_per_')
      unit_for(std_label) or units.inject { |quotient, divisor| quotient / divisor }
    end

    def create_product(str)
      std_label, units = collect_product_units(str)
      unit_for(std_label) or units.inject { |product, multiplier| product * multiplier } unless units.size < 2
    end

    def collect_product_units(str)
      return nil, [] if str.nil? or str.empty?
      prefix = str[/[[:alnum:]]+/]
      exponent = LABEL_EXPONENT_HASH[prefix.to_sym]
      if exponent.nil? then
        label, unit = slice_atomic_unit(str)
        rest_label, rest_units = collect_product_units(str[label.length + 1..-1])
        return "#{unit.label}_#{rest_label}".to_sym, [unit].concat(rest_units)
      else
        label, unit = slice_atomic_unit(str[prefix.length + 1..-1])
        return "#{prefix}_#{unit.label}".to_sym, Array.new(exponent, unit)
      end
    end

    # Returns the Unit which matches the str prefix.
    #
    # Raises MeasurementError if the unit could not be determined.
    def slice_atomic_unit(str)
      label = ''
      str.scan(/_?[^_]+/) do |chunk|
        label << chunk
        unit = create_atomic(label)
        return label, unit if unit
      end
      raise MeasurementError.new("Unit '#{str}' not found")
    end

    # Returns the +[scale, axis]+ pair parsed from the label.
    def partition_atomic_label(label)
      # singularize the label if it contains more than two letters and ends in s but not ss. this condition
      # avoids incorrect singularization of, e.g., ms (millisecond) and gauss.
      label = label.singularize if label =~ /[[:alnum:]][^s]s$/
      scalar, axis = parse_atomic_label(label) { |label| match_axis_label_suffix(label) }
      return scalar, axis unless scalar.nil? and axis.nil?
      parse_atomic_label(label) { |label| match_axis_abbreviation_suffix(label) }
    end

    def parse_atomic_label(label)
      # match the axis from the label suffix
      suffix, axis = yield label
      return nil, axis if axis.nil? or suffix == label
      prefix = suffix.nil? ? label : label[0...-suffix.to_s.length]
      # remove trailing separator from prefix if necessary,
      # e.g. the "milli_meter" prefix "milli_" becomes "milli"
      prefix = prefix[0, prefix.length - 1] if prefix[prefix.length - 1] == '_'
      # match the remaining prefix part of the label to a scalar
      scalar = match_scalar(prefix)
      return nil, nil if scalar.nil?
      return scalar, axis
    end

    # Returns the axis label and Unit which match on the label suffix substring, or nil
    # if no match. For example,
    #   match_axis_label_suffix(:millimeter)
    # returns "meter" and the meter Unit.
    def match_axis_label_suffix(str)
      best = [nil, nil]
      Unit.each do |unit|
        label_s = unit.label.to_s
        best = [label_s, unit] if suffix?(label_s, str) and (best.first.nil? or label_s.length > best.first.length)
      end
      best
    end

    # Returns the axis abbreviation and Unit which match on the label suffix substring, or nil
    # if no match. For example,
    #   match_axis_abbreviation_suffix(:mm)
    # returns "meter" and the meter Unit.
    def match_axis_abbreviation_suffix(str)
      best = [nil, nil]
      Unit.each do |unit|
        unit.abbreviations.each do |abbrev|
          abbrev_s = abbrev.to_s
          best = abbrev_s, unit if suffix?(abbrev_s, str) and (best.first.nil? or abbrev_s.length > best.first.length)
        end
      end
      best
    end

    # Returns the Factor which matches the label, or nil if no match.
    def match_scalar(label)
      label = label.to_sym
      Factor.detect do |factor|
        return factor if factor.label == label or factor.abbreviation == label
      end
    end

    # Returns whether text ends in suffix.
    def suffix?(suffix, text)
      len = suffix.length
      len <= text.length and suffix == text[-len, len]
    end
  end
end
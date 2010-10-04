UOM: Unit of Measure library
============================

**Git**:          [http://github.com/caruby/uom](http://github.com/caruby/uom)    
**Author**:       OHSU Knight Cancer Institute    
**Copyright**:    2010    
**License**:      MIT License    
**Latest Version**: 1.2.1    
**Release Date**: September 30th 2010    

Synopsis
--------

UOM implements Units of Measurement based on the
[http://physics.nist.gov/Pubs/SP330/sp330.pdf](International System of Units) (SI).
The base SI units, metric scalar factors and all possible combinations of these units
are supported out of the box.

Common alternative non-metric measurement systems, e.g. US Customary units, are
supported with conversions between these units and the SI units.
Additional units can be defined with conversion to an existing unit.
UOM infers full conversion capability between units of the same dimension from
the minimal number of conversion definitions.

Arithmetic operations between UOM Measurement objects converts the measurement units
and scalar factors as necessary, including unit products, quotients and powers of
arbitrary complexity.

Feature List
------------

1. Built-in support for standard scientific units

2. Conversion between arbitrary unit combinations

3. Custom unit definition

4. Measurement parser

Installing
----------

To install UOM, use the following command:

    $ gem install caruby-uom

(Add `sudo` if you're installing under a POSIX system as root)

Alternatively, if you've checked the source out directly, you can call
`rake install` from the root project directory.

Usage
-----

#### Create a Measurement
    require 'uom'

    UOM::Measurement.new(:g, 1) #=> 1 gram
    UOM::Measurement.new(:mg, 1) #=> 1 milligram
    UOM::Measurement.new(:mg_per_l, 1) #=> 1 milligram per liter

#### Scale a Measurement

    UOM::Measurement.new(:g, 1).as(:mg) #=> 1000 milligrams

#### Measurement arithmetic

    UOM::Measurement.new(:g, 1) * 2 #=> 2 grams
    UOM::Measurement.new(:g, 2) / UOM::Measurement.new(:l, 1) #=> 2 milligrams per liter

#### Parse a measurement String

    "1 g".to_measurement #=> 1 gram Measurement
    "1 gm".to_measurement #=> 1 gram Measurement
    "2 grams".to_measurement #=> 2 gram Measurement

#### Convert a Measurement

    UOM::Measurement.new(:g, 2).to_f #=> 2.0
    UOM::Measurement.new(:g, 1).to_s #=> "1 gram"
    UOM::Measurement.new(:g, 2).to_s #=> "2 grams"

#### Label a novel unit

    module UOM
      # joule-pecks per erg-gauss
      JPEG = Unit.for((JOULE * PECK) / (ERG * GAUSS)).add_abbreviation(:jpeg)
    end
    UOM::Measurement.new(:jpeg, 1) #=> 1 jpeg

Changelog
---------

- **September.30.10**: 2010.1 release
    - Initial public release

Copyright
---------

UOM &copy; 2010 by [Oregon Health & Sciences University](mailto:loneyf@ohsu.edu).
UOM is licensed under the MIT license. Please see the LICENSE and LEGAL
documents for more information.

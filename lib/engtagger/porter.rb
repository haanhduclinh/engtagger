#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

module Stemmable
  # Porter stemmer in Ruby.
  #
  # This is the Porter stemming algorithm, ported to Ruby from the
  # version coded up in Perl.  It's easy to follow against the rules
  # in the original paper in:
  #
  #   Porter, 1980, An algorithm for suffix stripping, Program, Vol. 14,
  #   no. 3, pp 130-137,
  #
  # See also http://www.tartarus.org/~martin/PorterStemmer
  #
  # Send comments to raypereda@hotmail.com
  #

  def stem_porter

    # make a copy of the given object and convert it to a string.
    w = self.dup.to_str

    return w if w.length < 3

    # now map initial y to Y so that the patterns never treat it as vowel
    w[0] = 'Y' if w[0] == ?y

    # Step 1a
    if w =~ /(ss|i)es$/
      w = $` + $1
    elsif w =~ /([^s])s$/
      w = $` + $1
    end

    # Step 1b
    if w =~ /eed$/
      w.chop! if $` =~ MGR0
    elsif w =~ /(ed|ing)$/
      stem = $`
      if stem =~ VOWEL_IN_STEM
        w = stem
	case w
        when /(at|bl|iz)$/             then w << "e"
        when /([^aeiouylsz])\1$/       then w.chop!
        when /^#{CC}#{V}[^aeiouwxy]$/o then w << "e"
        end
      end
    end

    if w =~ /y$/
      stem = $`
      w = stem + "i" if stem =~ VOWEL_IN_STEM
    end

    # Step 2
    if w =~ SUFFIX_1_REGEXP
      stem = $`
      suffix = $1
      # print "stem= " + stem + "\n" + "suffix=" + suffix + "\n"
      if stem =~ MGR0
        w = stem + STEP_2_LIST[suffix]
      end
    end

    # Step 3
    if w =~ /(icate|ative|alize|iciti|ical|ful|ness)$/
      stem = $`
      suffix = $1
      if stem =~ MGR0
        w = stem + STEP_3_LIST[suffix]
      end
    end

    # Step 4
    if w =~ SUFFIX_2_REGEXP
      stem = $`
      if stem =~ MGR1
        w = stem
      end
    elsif w =~ /(s|t)(ion)$/
      stem = $` + $1
      if stem =~ MGR1
        w = stem
      end
    end

    #  Step 5
    if w =~ /e$/
      stem = $`
      if (stem =~ MGR1) ||
          (stem =~ MEQ1 && stem !~ /^#{CC}#{V}[^aeiouwxy]$/o)
        w = stem
      end
    end

    if w =~ /ll$/ && w =~ MGR1
      w.chop!
    end

    # and turn initial Y back to y
    w[0] = 'y' if w[0] == ?Y

    w
  end


  #
  # make the stem_porter the default stem method, just in case we
  # feel like having multiple stemmers available later.
  #
  alias stem stem_porter

end

# Add stem method to all Strings
class String
  include Stemmable
end

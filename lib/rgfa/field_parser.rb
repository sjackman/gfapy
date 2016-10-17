require "json"
require_relative "byte_array"
require_relative "numeric_array"
require_relative "cigar"
require_relative "trace"
require_relative "error"
require_relative "field_array"
require_relative "alignment"

#
# Methods to parse the string representations of the GFA fields
# @api private
#
module RGFA::FieldParser

  # Parse a string representation of a GFA field value
  # @raise [RGFA::FormatError] if the value is not valid
  # @param datatype [RGFA::Line::FIELD_DATATYPE]
  def parse_gfa_field(datatype: nil,
                      validate_strings: true,
                      fieldname: nil)
    case datatype
    when :any
      return self
    when :A, :Z
      validate_gfa_field!(datatype, fieldname: fieldname) if validate_strings
      return self
    when :seq
      validate_gfa_field!(datatype, fieldname: fieldname) if validate_strings
      value = self.to_sequence
      return value
    when :crt
      return to_sym
    when :lbl
      validate_segment_name!
      validate_gfa_field!(datatype, fieldname: fieldname) if validate_strings
      return to_sym
    when :orn
      validate_gfa_field!(datatype, fieldname: fieldname) if validate_strings
      return to_sym
    when :i
      begin
        return Integer(self)
      rescue
        raise RGFA::FormatError,
        "Wrong value format for field #{fieldname}:\n"+
        "Datatype: Integer\n"+
        "Content: #{self}"
      end
    when :pos
      begin
        value = Integer(self)
        raise if value < 0
      rescue
        raise RGFA::FormatError,
        "Wrong value format for field #{fieldname}:\n"+
        "Datatype: Integer >= 0\n"+
        "Content: #{self}"
      end
      return value
    when :f
      begin
        return Float(self)
      rescue
        raise RGFA::FormatError,
        "Wrong value format for field #{fieldname}:\n"+
        "Datatype: Float\n"+
        "Content: #{self}"
      end
    when :H
      value = to_byte_array
      return value
    when :B
      value = to_numeric_array
      return value
    when :J
      value = JSON.parse(self)
      # RGFA convention for array of fields
      if value.kind_of?(Array) and value.rgfa_field_array?
        value = value.to_rgfa_field_array
      end
      return value
    when :cig
      value = to_alignment(false)
      return value
    when :aln
      value = to_alignment
      return value
    when :cgs
      value = split(",").map do |c|
        c = c.to_alignment(false)
        c
      end
      return value
    when :lbs
      value = split(",").map do |l|
        o = l[-1].to_sym
        l = l[0..-2]
        if validate_strings
          l.validate_gfa_field!(:lbl, fieldname: "#{fieldname} "+
                               "(entire field content: #{self})" )
        end
        os = [l.to_sym, o].to_oriented_segment
        os
      end
      return value
    else
      raise RGFA::TypeError,
        "Datatype unknown: #{datatype.inspect}"
    end
  end

  # Parses a tag in the form tagname:datatype:value
  # and parses the value according to the datatype
  # @raise [RGFA::FormatError] if the string does not represent
  #   a tag
  # @return [Array(Symbol, RGFA::Line::FIELD_DATATYPE, String)]
  #   the parsed content of the field
  def parse_gfa_tag
    if self =~ /^([A-Za-z][A-Za-z0-9]):([AifZJHB]):(.+)$/
      return $1.to_sym, $2.to_sym, $3
    else
      raise RGFA::FormatError,
        "Expected GFA tag, found: #{self.inspect}"
    end
  end

end

class String
  include RGFA::FieldParser
end

# An edge line of a GFA2 file
class RGFA::Line::Edge::GFA2 < RGFA::Line::Edge

  RECORD_TYPE = :E
  POSFIELDS = [:eid, :sid1, :sid2, :beg1, :end1, :beg2, :end2, :alignment]
  PREDEFINED_TAGS = []
  DATATYPE = {
    :eid => :optional_identifier_gfa2,
    :sid1 => :oriented_identifier_gfa2,
    :sid2 => :oriented_identifier_gfa2,
    :beg1 => :position_gfa2,
    :end1 => :position_gfa2,
    :beg2 => :position_gfa2,
    :end2 => :position_gfa2,
    :alignment => :alignment_gfa2,
  }
  FIELD_ALIAS = { :name => :eid }
  REFERENCE_FIELDS = [:sid1, :sid2]
  REFERENCE_RELATED_FIELDS = [:beg1, :end1, :beg2, :end2]
  DEPENDENT_LINES = [:ordered_groups, :unordered_groups]
  OTHER_REFERENCES = []

  define_field_methods

  alias_method :to_sym, :eid

end

require_relative "common/from_to.rb"
require_relative "common/alignment_type.rb"
require_relative "gfa2/to_gfa1.rb"
require_relative "gfa2/alignment_type.rb"
require_relative "gfa2/references.rb"

class RGFA::Line::Edge::GFA2
  include RGFA::Line::Edge::Common::FromTo
  include RGFA::Line::Edge::Common::AlignmentType
  include RGFA::Line::Edge::GFA2::AlignmentType
  include RGFA::Line::Edge::GFA2::ToGFA1
  include RGFA::Line::Edge::GFA2::References
end
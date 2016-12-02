module RGFA::Line::Edge::Link::Equivalence

  # Computes an hash for including a link in an Hash tables,
  # so that the hash of a link and its complement is the same.
  # Thereby, tags are not considered.
  # @see #eql?
  def hash
    from_end.to_s.hash + to_end.to_s.hash +
      overlap.to_s.hash + overlap.complement.to_s.hash
  end

  # Compares two links and determine their equivalence.
  # Thereby, tags are not considered.
  #
  # @note Inverting the strand of both links and reversing
  #   the CIGAR operations (order/type), one obtains an
  #   equivalent complement link.
  #
  # @param other [RGFA::Line::Edge::Link] a link
  # @return [Boolean] are self and other equivalent?
  # @see #==
  # @see #same?
  # @see #complement?
  def eql?(other)
    return (same?(other) or complement?(other))
  end

  # Compares the tags of two links.
  #
  # @note This method shall be overridden if custom tags
  #   are defined, which have a ``complementation'' operation which determines
  #   their value in the equivalent but complement link.
  #
  # @param other [RGFA::Line::Edge::Link] a link
  # @return [Boolean] are self and other equivalent?
  # @see #==
  def eql_tags?(other)
    (self.tagnames.sort == other.tagnames.sort) and
      tagnames.each {|fn| self.get(fn) == other.get(fn)}
  end

  # Compares two links and determine their equivalence.
  # Tags must have the same content.
  #
  # @note Inverting the strand of both links and reversing
  #   the CIGAR operations (order/type), one obtains an equivalent
  #   link.
  #
  # @param other [RGFA::Line::Edge::Link] a link
  # @return [Boolean] are self and other equivalent?
  # @see #eql?
  # @see #eql_tags?
  #def ==(other)
  #  eql?(other) and eql_tags?(other)
  #end

  # Compares two links and determine their equivalence.
  # Thereby, tags are not considered.
  #
  # @param other [RGFA::Line::Edge::Link] a link
  # @return [Boolean] are self and other equivalent?
  # @see #eql?
  # @see #complement?
  # @see #==
  def same?(other)
    (from_end == other.from_end and
      to_end == other.to_end and
      overlap == other.overlap)
  end

  # Compares the link to the complement of another link
  # and determine their equivalence.
  # Thereby, tags are not considered.
  #
  # @param other [RGFA::Line::Edge::Link] the other link
  # @return [Boolean] are self and the complement of other equivalent?
  # @see #eql?
  # @see #same?
  # @see #==
  def complement?(other)
    (from_end == other.to_end and
      to_end == other.from_end and
      overlap == other.overlap.complement)
  end

  # Compares a link and optionally the complement link,
  # with two oriented_segments and optionally an overlap.
  # @param [RGFA::OrientedLine] other_oriented_from
  # @param [RGFA::OrientedLine] other_oriented_to
  # @param allow_complement [Boolean]
  #    shall the complement link also be considered?
  # @param [RGFA::Alignment::CIGAR] other_overlap compared only if not empty
  # @return [Boolean] does the link or, if +allow_complement+,
  #   the complement link go from the first
  #   oriented segment to the second with an overlap equal to the provided one
  #   (if not empty)?
  def compatible?(other_oriented_from, other_oriented_to, other_overlap = [],
                  allow_complement = true)
    other_overlap = other_overlap.to_alignment(version: :gfa1, valid: true)
    if compatible_direct?(other_oriented_from, other_oriented_to, other_overlap)
      return true
    elsif allow_complement
      return compatible_complement?(other_oriented_from,
                                    other_oriented_to,
                                    other_overlap)
    else
      return false
    end
  end

  # Compares a link with two oriented segments and optionally an overlap.
  # @param [RGFA::OrientedLine] other_oriented_from
  # @param [RGFA::OrientedLine] other_oriented_to
  # @param [RGFA::Alignment::CIGAR] other_overlap compared only if not empty
  # @return [Boolean] does the link go from the first
  #   oriented segment to the second with an overlap equal to the provided one
  #   (if not empty)?
  def compatible_direct?(other_oriented_from, other_oriented_to,
                         other_overlap = [])
    (oriented_from == other_oriented_from and
     oriented_to == other_oriented_to) and
     (overlap.empty? or other_overlap.empty? or (overlap == other_overlap))
  end

  # Compares the complement link with two oriented segments and optionally an
  # overlap.
  # @param [RGFA::OrientedLine] other_oriented_from
  # @param [RGFA::OrientedLine] other_oriented_to
  # @param [RGFA::Alignment::CIGAR] other_overlap compared only if not empty
  # @return [Boolean] does the complement link go from the first
  #   oriented segment to the second with an overlap equal to the provided one
  #   (if not empty)?
  def compatible_complement?(other_oriented_from, other_oriented_to,
                          other_overlap = [])
    (oriented_to == other_oriented_from.invert and
     oriented_from == other_oriented_to.invert) and
     (overlap.empty? or other_overlap.empty? or
        (overlap == other_overlap.complement))
  end

  private

  def complement_ends?(other)
    (from_end == other.to_end and
      to_end == other.from_end)
  end

end

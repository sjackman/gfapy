## Positional fields

Most lines in GFA have positional fields (Headers are an exception).
During parsing, if a line is encountered, which has too less or too many
positional fields, an exception will be thrown.
The correct number of positional fields is record type-specific.

Positional fields are recognized by its position in the line.
Each positional field has an implicit field name and datatype associated
with it.

### Field names

The field names are derived from the specification. Lower case versions
of the field names are used and spaces are subsituted with underscores.

The following tables shows the field names used in RGFA, for each kind of line.
Headers have no positional fields. Comments and custom lines follow particular
rules, see the respective chapters.

#### GFA1 field names

| Record Type | Field 1         | Field 2             | Field 3        | Field 4         | Field 5       | Field 6       |
|-------------|-----------------|---------------------|----------------|-----------------|---------------|---------------|
| Segment     | ```name```      | ```sequence```      |                |                 |               |               |
| Link        | ```from```      | ```from_orient```   | ```to```       | ```to_orient``` | ```overlap``` |               |
| Containment | ```from```      | ```from_orient```   | ```to```       | ```to_orient``` | ```pos```     | ```overlap``` |
| Path        | ```path_name``` | ```segment_names``` | ```overlaps``` |                 |               |               |

#### GFA2 field names

| Record Type | Field 1   | Field 2     | Field 3        | Field 4     | Field 5     | Field 6     | Field 7     | Field 8         | Field 9         |
|-------------|-----------|-------------|----------------|-------------|-------------|-------------|-------------|-----------------|-----------------|
| Segment     | ```sid``` | ```slen ``` | ```sequence``` |             |             |             |             |                 |                 |
| Edge        | ```eid``` | ```sid1 ``` | ```or2     ``` | ```sid2 ``` | ```beg1 ``` | ```end1 ``` | ```beg2 ``` | ```end2     ``` | ```alignment``` |
| Fragment    | ```sid``` | ```or   ``` | ```external``` | ```s_beg``` | ```s_end``` | ```f_beg``` | ```f_end``` | ```alignment``` |                 |
| Gap         | ```gid``` | ```sid1 ``` | ```d1      ``` | ```d2   ``` | ```sid2 ``` | ```disp ``` | ```var  ``` |                 |                 |
| U\ Group    | ```pid``` | ```items``` |                |             |             |             |             |                 |                 |
| O\ Group    | ```pid``` | ```items``` |                |             |             |             |             |                 |                 |

### Datatypes

The datatype of each positional field is described in the specification and
cannot be changed (differently from tags).  Here is a short description of the
Ruby classes used to represent data for different datatypes. For some
complex cases, more details are found in the following chapters.

#### Placeholders

The positional fields in GFA can never be empty. However, there are some
fields with optional values. If a value is not specified, a placeholder
character is used instead (```*```). Such undefined values are represented
in RGFA by the Placeholder class, which is described more in detail in the
Placeholders chapter.

#### Arrays

The ```items``` field in unordered and ordered groups
and the ```segment_names``` and ```overlaps``` fields in paths are
lists of objects and are represented by Array instances.

#### Orientations

Orientations are represented by symbols. Applying the ```invert``` method
on an orientation symbol returns the other orientation, e.g.
```ruby
:+.invert # => :-
```

#### Identifiers

The identifier of the line itself (available for S, P, E, G, U, O lines)
can always be accessed in RGFA using the ```name``` alias and is represented
in RGFA by a Symbol. If it is optional (E, G, U, O lines)
and not specified, it is represented by a Placeholder instance.
The fragment identifier is also a Symbol.

Identifiers which refer to other lines are also present in some line types
(L, C, E, G, U, O, F). These are never placeholders and in stand-alone lines
are represented by symbols. In connected lines they are references to the Line
instances to which they refer to (see the References chapter).

#### Oriented identifiers

Oriented identifiers (e.g. ```segment_names``` in GFA1 paths)
are represented by elements of the class
```RGFA::OrientedSegment```. The ```segment``` method of the oriented
segments returns the segment identifier (or segment reference in connected
path lines) and the ```orient``` method returns the orientation symbol.
The ```name``` method returns the symbol of the segment, even if this is
a reference to a segment.

Calling ```invert``` returns an oriented segment, with inverted orientation.
To set the two attributes the methods ```segment=``` and ```orient=```
are available.

Examples:
```ruby
p = "P\tP1\ta+,b-\t*".to_rgfa_line
p.segment_names # => [OrientedSegment(:a,:+),OrientedSegment(:b,:-)]
p[0].segment # => :a
p[0].name # => :a
p[0].orient # => :+
p[0].invert # => OrientedSegment(:a,:-)
p[0].orient = :-
p[0].segment = "S\tX\t*".to_rgfa_line
p[0] # => OrientedSegment(RGFA::Line("S\tX\t*"), :-)
p[0].name # => :X
```

#### Sequences

Sequences (S field sequence) are represented by strings in RGFA.
Depending on the GFA version, the alphabet definition is more or less
restrictive. The definitions are correctly applied by the validation methods.

The method #rc is provided to compute the reverse complement of a nucleotidic
sequence. The extended IUPAC alphabet is understood by the method. Applied to
non nucleotidic sequences, the results will be meaningless:
```ruby
"gcat".rc # => "atgc"
"*".rc # => "*" (placeholder)
"yatc".rc # => "gatr" (wildcards)
"gCat".rc # => "atGc" (case remains)
"ctg".rc(rna: true) # => "cug"
```

#### Integers and positions

The C lines ```pos``` field and the G lines ```disp``` and ```var``` fields
are represented by integers. The ```var``` field is optional,
and thus can be also a placeholder. Positions are 0-based coordinates.

The position fields of GFA2 E lines (```beg1, beg2, end1, end2```) and
F lines (```s_beg, s_end, f_beg, f_end```) contain a dollar symbol as suffix
if the position is equal to the segment length. For more information,
see the Positions chapter.

#### Alignments

Alignments are always optional, ie they can be placeholders. If they are
specified they are CIGAR alignments or, only in GFA2, trace alignments.
For more details, see the Alignments chapter.

#### GFA1 datatypes

| Datatype                 | Record Type | Fields                       |
|--------------------------|-------------|------------------------------|
| Identifier               | Segment     | ```name                  ``` |
|                          | Path        | ```path_name             ``` |
|                          | Link        | ```from, to              ``` |
|                          | Containment | ```from, to              ``` |
| [Identifier+Orientation] | Path        | ```segment_names         ``` |
| Orientation              | Link        | ```from_orient, to_orient``` |
|                          | Containment | ```from_orient, to_orient``` |
| Sequence                 | Segment     | ```sequence              ``` |
| Alignment                | Link        | ```overlap               ``` |
|                          | Containment | ```overlap               ``` |
| [Alignment]              | Path        | ```overlaps              ``` |
| Position                 | Containment | ```pos                   ``` |

#### GFA2 datatypes

| Datatype                 | Record Type | Fields                           |
|--------------------------|-------------|----------------------------------|
| Itentifier               | Segment     | ```sid                       ``` |
|                          | Edge        | ```eid, sid1, sid2           ``` |
|                          | Gap         | ```gid, sid1, sid2           ``` |
|                          | Fragment    | ```sid, external             ``` |
|                          | U/O Group   | ```pid                       ``` |
| [Identifier]             | U/O Group   | ```items                     ``` |
| Orientation              | Edge        | ```or2                       ``` |
| Direction                | Gap         | ```d1, d2                    ``` |
| Sequence                 | Segment     | ```sequence                  ``` |
| Alignment                | Edge        | ```alignment                 ``` |
|                          | Fragment    | ```alignment                 ``` |
| Position                 | Edge        | ```beg1, end1, beg2, end2    ``` |
|                          | Fragment    | ```s_beg, s_end, f_beg, f_end``` |
| Integer                  | Gap         | ```disp, var                 ``` |

### Reading and writing positional fields

The ```RGFA::Line#positional_fieldnames``` method returns the list of the names
(as symbols) of the positional fields of a line.

The positional fields can be read using a method on the RGFA line object, which
is called as the field name.  Setting the value is done with an equal sign
version of the field name method (e.g. segment.slen = 120).  In alternative,
the ```set(fieldname, value)``` and ```get(fieldname)``` methods can also be
used.

When a field is read, the value is converted into an appropriate object.  The
string representation of a field can be read using the
```field_to_s(fieldname)``` method.

When setting a value, the user can specify the value of a tag either as a Ruby
object, or as the string representation of the value.

### Validation

The content of all positional fields must be a correctly formatted
string according to the rules given in the GFA specifications (or a Ruby object
whose string representation is a correctly formatted string).

Depending on the validation level, more or less checks are done automatically
(see validation chapter).  Not regarding which validation level is selected,
the user can trigger a manual validation using the
```validate_field(fieldname)``` method for a single field, or using
```validate```, which does a full validation on the whole line, including all
positional fields.

### Aliases

For some fields, aliases are defined, which can be used in all contexts
where the original field name is used (i.e. as parameter of a method, and
the same setter and getter methods defined for the original field name are
also defined for each alias, see below).

#### Name

Different record types have an identifier field:
segments (name in GFA1, sid in GFA2), paths (path_name), edge (eid),
fragment (sid), gap (gid), groups (pid).

All these fields are aliased to ```name```. This allows the user
for example to set the identifier of a line using the
```name=(value)``` method using the same syntax for different record
types (segments, edges, paths, fragments, gaps and groups).

#### Version-specific field names

For segments the GFA1 name and the GFA2 sid are equivalent
fields. For this reason an alias ```sid``` is defined for GFA1 segments
and ```name``` for GFA2 segments.

#### Crypical field names

The definition of from and to for containments is somewhat cryptical.
Therefore following aliases have been defined for containments:
container[_orient] for from[_orient]; contained[_orient] for to[_orient]

### Summary of positional fields-related API methods

```
RGFA::Line#<fieldname>/<fieldname>=
RGFA::Line#get/set
RGFA::Line#validate_field/validate
Symbol#invert
String#rc
```

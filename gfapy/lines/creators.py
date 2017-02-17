import gfapy

class Creators:
  def add_line(self, gfa_line):
    if self._version == "gfa1":
      self.__add_line_GFA1(gfa_line)
    elif self._version == "gfa2":
      self.__add_line_GFA2(gfa_line)
    elif self._version is None:
      self.__add_line_unknown_version(gfa_line)
    else:
      raise gfapy.AssertionError("This point should never be reached")
    return self

  append = add_line

  def process_line_queue(self):
    if self._version is None:
      self._version = self._version_guess
    for i in range(0,len(self._line_queue)):
      self.add_line(self._line_queue[i])
    self._line_queue = []

  def _register_line(self, gfa_line):
    self._api_private_check_gfa_line(gfa_line, "_register_line")
    storage_key = gfa_line.__class__.STORAGE_KEY
    if storage_key == "merge":
      self._records[gfa_line.record_type]._merge(gfa_line)
    elif storage_key == "name":
      if gfa_line.record_type not in self._records:
        self._records[gfa_line.record_type] = {}
      if gfapy.is_placeholder(gfa_line.name):
        if None not in self._records[gfa_line.record_type]:
          self._records[gfa_line.record_type][None] = []
        self._records[gfa_line.record_type][None].append(gfa_line)
      else:
        self._records[gfa_line.record_type][gfa_line.name] = gfa_line
    elif storage_key == "external":
      if gfa_line.external.line not in self._records[gfa_line.record_type]:
        self._records[gfa_line.record_type][gfa_line.external.line] = []
      self._records[gfa_line.record_type][gfa_line.external.line].append(\
          gfa_line)
    elif storage_key is None:
      if gfa_line.record_type not in self._records:
        self._records[gfa_line.record_type] = []
      self._records[gfa_line.record_type].append(gfa_line)

  def __add_line_unknown_version(self, gfa_line):
    if isinstance(gfa_line, str):
      rt = gfa_line[0]
    elif isinstance(gfa_line, gfapy.Line):
      rt = gfa_line.record_type
    else:
      raise gfapy.ArgumentError(\
          "Only strings and gfapy.Line instances can be added")
    if rt == "#":
      if isinstance(gfa_line, str):
        gfa_line = gfapy.Line.from_string(gfa_line)
      gfa_line.connect(self)
    elif rt == "H":
      if isinstance(gfa_line, str):
        gfa_line = gfapy.Line.from_string(gfa_line, vlevel=self._vlevel)
      self.header._merge(gfa_line)
      if gfa_line.VN:
        if gfa_line.VN == "1.0":
          self._version = "gfa1"
        elif gfa_line.VN == "2.0":
          self._version = "gfa2"
        else:
          self._version = gfa_line.VN
        self._version_explanation = "specified in header VN tag"
        if self._vlevel > 0:
          self._validate_version()
        self.process_line_queue()
    elif rt == "S":
      if isinstance(gfa_line, str):
        gfa_line = gfapy.Line.from_string(gfa_line, vlevel=self._vlevel)
      self._version = gfa_line.version
      self._version_explatation = \
          "implied by: syntax of S {} line".format(gfa_line.name)
      self.process_line_queue()
      gfa_line.connect(self)
    elif rt in ["E", "F", "G", "U", "O"]:
      self._version = "gfa2"
      self._version_explatation = "implied by: presence of a {} line".format(rt)
      if isinstance(gfa_line, str):
        gfa_line = gfapy.Line.from_string(gfa_line, vlevel=self._vlevel,
            version=self._version)
      self.process_line_queue()
      gfa_line.connect(self)
    elif rt in ["L", "C", "P"]:
      self._version_guess = "gfa1"
      self._line_queue.append(gfa_line)
    else:
      self._line_queue.append(gfa_line)

  def __add_line_GFA1(self, gfa_line):
    if isinstance(gfa_line, str):
      if gfa_line[0] == "S":
        gfa_line = gfapy.Line.from_string(gfa_line, vlevel=self._vlevel)
      else:
        gfa_line = gfapy.Line.from_string(gfa_line, vlevel=self._vlevel,
                                        version="gfa1")
    elif gfa_line.__class__ in gfapy.Lines.GFA2Specific:
      raise gfapy.VersionError(
        "Version: 1.0 ({})\n".format(self._version_explanation)+
        "Cannot add instance of incompatible line type "+
        str(type(gfa_line)))
    if gfa_line.record_type == "H":
      if self._vlevel > 0 and gfa_line.VN and gfa_line.VN != "1.0":
        raise gfapy.VersionError(
          "Header line specified wrong version ({})\n".format(gfa_line.VN)+
          "Line: {}\n".format(gfa_line)+
          "File version: 1.0 ({})".format(self._version_explanation))
      self.header._merge(gfa_line)
    elif gfa_line.record_type == "S":
      if gfa_line.version == "gfa2":
        raise gfapy.VersionError(
          "Version: 1.0 ({})\n".format(self._version_explanation)+
          "GFA2 segment found: {}".format(gfa_line))
      gfa_line.connect(self)
    elif gfa_line.record_type in ["L", "P", "C", "#"]:
      gfa_line.connect(self)
    else:
      raise gfapy.AssertionError(
        "Invalid record type {}. This should never happen".format(rt))

  def __add_line_GFA2(self, gfa_line):
    if isinstance(gfa_line, str):
      if gfa_line[0] == "S":
        gfa_line = gfapy.Line.from_string(gfa_line, vlevel=self._vlevel)
      else:
        gfa_line = gfapy.Line.from_string(gfa_line, vlevel=self._vlevel,
                                        version="gfa2")
    elif gfa_line.__class__ in gfapy.Lines.GFA1Specific:
      raise gfapy.VersionError(
        "Version: 2.0 ({})\n".format(self._version_explanation)+
        "Cannot add instance of incompatible line type "+
        str(type(gfa_line)))
    if gfa_line.record_type == "H":
      if self._vlevel > 0 and gfa_line.VN and gfa_line.VN != "2.0":
        raise gfapy.VersionError(
          "Header line specified wrong version ({})\n".format(gfa_line.VN)+
          "Line: {}\n".format(gfa_line)+
          "File version: 2.0 ({})".format(self._version_explanation))
      self.header._merge(gfa_line)
    elif gfa_line.record_type == "S":
      if gfa_line.version == "gfa1":
        raise gfapy.VersionError(
          "Version: 2.0 ({})\n".format(self._version_explanation)+
          "GFA1 segment found: {}".format(gfa_line))
      gfa_line.connect(self)
    else:
      gfa_line.connect(self)

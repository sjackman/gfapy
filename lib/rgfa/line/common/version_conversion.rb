module RGFA::Line::Common::VersionConversion

  [:gfa1, :gfa2].each do |shall_version|
    # @note RGFA::Line subclasses do not usually redefine this method, but
    #   the corresponding versioned to_a method
    # @return [String] a string representation of self
    define_method :"to_#{shall_version}_s" do
      send(:"to_#{shall_version}_a").join(RGFA::Line::SEPARATOR)
    end

    # @note RGFA::Line subclasses can redefine this method to convert
    #   between versions
    # @return [Array<String>] an array of string representations of the fields
    define_method :"to_#{shall_version}_a" do
      send(:to_a)
    end

    # @return [RGFA::Line] convertion to the selected version
    define_method :"to_#{shall_version}" do
      v = (shall_version == :gfa1) ? :"1.0" : :"2.0"
      if (v == version)
        return self
      else
        send(:"to_#{shall_version}_a").to_rgfa_line(version: v,
                                                    validate: @validate)
      end
    end
  end

end
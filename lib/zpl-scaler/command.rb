module ZplScaler

  # Data class that holds the name & params of a ZPL command.
  class ZplCommand
    attr_accessor :name
    attr_accessor :params

    def initialize(name, params)
      @name = name
      @params = params
    end

    # Converts the command to a ZPL string.
    def to_zpl_string
      "^#{ @name }#{ @params.join(',') }"
    end
  end

end

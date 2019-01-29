require 'strscan'
require 'set'
require_relative './command'

module ZplScaler
  # NOTE: doesn't handle ZPL that changes the control char (default is assumed: '^')
  class ZplReader
    # Example format: ^XXparam1,param2,,param4
    # ZplCommand name: XX (the command is read as 2 chars, no more no less)
    # 4 (5) params (param 3 & 5 are not given)
    RX_ZPL_COMMAND = /\^([A-Z0-9@]{2})([^\^]*)/

    # Creates a new reader that will read ZPL commands from *content* string.
    def initialize(content, strip_spaces: true)
      @scanner = StringScanner.new content
      @strip_spaces = strip_spaces
    end

    # Returns the next zpl command if any, or nil.
    def next_command
      return if @scanner.eos?

      @scanner.scan(RX_ZPL_COMMAND)

      cmd_name = @scanner[1]
      raw_params = @scanner[2]
      if @strip_spaces
        raw_params = raw_params&.strip
      end

      params = raw_params&.split(',', -1) || []
      if @strip_spaces
        params.each { |param| param.strip! }
      end
      ZplCommand.new(cmd_name, params)
    end

    # Yields each ZPL command to the block. Stops when there are no more commands to read.
    def each_command
      while cmd = next_command
        yield cmd
      end
    end
  end
end

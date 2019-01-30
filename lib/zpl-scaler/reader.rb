require 'strscan'
require 'set'
require_relative './command'

module ZplScaler
  # NOTE: doesn't handle ZPL that changes the control char (default is assumed: '^')
  class ZplReader

    # Creates a new reader that will read ZPL commands from *content* string.
    def initialize(content)
      @scanner = StringScanner.new content
    end

    # Returns the next zpl command or ignored string if any, or nil.
    #
    # The ignored string can be a newlines, ignored chars, spaces.
    def next_token
      return if @scanner.eos?

      if chars_to_ignore = parse_ignore_chars
        return chars_to_ignore
      end

      parse_zpl_cmd
    end

    # Returns the next zpl command if any, or nil.
    def next_command
      while token = next_token
        if token.is_a?(ZplCommand)
          return token
        end
      end

      nil
    end

    # Yields each ZPL command to the block. Stops when there are no more commands to read.
    def each_command
      while cmd = next_command
        yield cmd
      end
    end

    protected

    def parse_zpl_cmd
      # Example format: ^XXparam1,param2,,param4
      # ZplCommand name: XX (the command is read as 2 chars, no more no less)
      # 4 (5) params (param 3 & 5 are not given)
      #
      # The command stops at the next `^` or newline.
      @scanner.scan(/\^([A-Z0-9@]{2})([^\^\n]*)/)

      cmd_name = @scanner[1]
      raw_params = @scanner[2]&.strip

      params = raw_params&.split(',', -1) || []
      params.each { |param| param.strip! }
      ZplCommand.new(cmd_name, params)
    end

    def parse_ignore_chars
      # scan until next command (just before the `^`)
      chars_skipped = @scanner.scan_until(/(?=\^)/)

      if chars_skipped.nil?
        # No more commands, return the rest
        rest = @scanner.rest
        @scanner.terminate
        return rest
      end

      if chars_skipped.empty?
        nil
      else
        chars_skipped
      end
    end
  end
end

require 'strscan'
require 'set'
require 'zpl-scaler/version'

module ZplScaler

  class Error < StandardError; end

  # Data class that holds the name & params of a ZPL command.
  class ZplCommand
    attr_accessor :name
    attr_accessor :params

    def initialize name, params
      @name = name
      @params = params
    end

    # Converts the command to a ZPL string.
    def to_zpl_string
      "^#{ @name }#{ @params.join(',') }"
    end
  end

  # NOTE: doesn't handle ZPL that changes the control char (default: '^')
  class ZplReader
    # Example format: ^XXparam1,param2,,param4
    # ZplCommand name: XX (the command is read as 2 chars, no more no less)
    # 4 (5) params (param 3 & 5 are not given)
    RX_ZPL_COMMAND = /\^([A-Z0-9]{2})([^\^]*)/

    # Returns the list of unique commands used in the given ZPL.
    def self.uniq_commands zpl_content
      uniq_cmds = Set.new
      new(zpl_content).each_command do |cmd|
        uniq_cmds << cmd.name
      end
      uniq_cmds.to_a
    end

    # Creates a new reader that will read ZPL commands from *content* string.
    def initialize content
      @scanner = StringScanner.new content
    end

    # Returns the next zpl command if any, or nil.
    def next_command
      return if @scanner.eos?

      @scanner.scan(RX_ZPL_COMMAND)

      cmd_name = @scanner[1]
      raw_params = @scanner[2]

      ZplCommand.new(cmd_name, raw_params&.split(',') || [])
    end

    # Yields each ZPL command to the block. Stops when there are no more commands to read.
    def each_command
      while cmd = next_command
        yield cmd
      end
    end
  end

  # TODO: doc
  # It works by parsing ZPL commands, then edit the parameters of specific commands
  # to scale the coordinates to the new dpi
  #
  # NOTE: Cannot work for embedded images
  class Scaler
    COMMANDS_PARAM_INDEXES_TO_SCALE = {
      # ^MN - Media Tracking
      #
      # Param 0: media being used
      # Param 1: black mark offset in dots (optional)
      "MN" => [1],

      # ^BY - Bar Code Field Default
      #
      # Param 0: module width in dots
      # Param 1: wide bar to narrow bar width ratio (float)
      # Param 2: bar code height in dots
      "BY" => [0, 2],

      # ^FO - Field Origin
      #
      # Param 0: x-axis location in dots
      # Param 1: y-axis location in dots
      # Param 2: justification (enum)
      "FO" => [0, 1],

      # ^B2 - Interleaved 2 of 5 Bar Code
      #
      # Param 0: orientation (enum)
      # Param 1: bar code height in dots
      # Param 2: print interpretation line above code (bool)
      "B2" => [1],

      # ^GB - Graphic Box
      #
      # Param 0: box width in dots
      # Param 1: box height in dots
      # Param 2: border thickness
      # Param 3: line color (enum)
      # Param 4: degree of corner rounding (enum)
      "GB" => [0, 1, 2],

      # ^BC - Code 128 Bar Code (Subsets A, B, and C)
      #
      # Param 0: orientation (enum)
      # Param 1: bar code height in dots
      # Param 2: print interpretation line (bool)
      # Param 3: print interpretation line above code (bool)
      # Param 4: UCC check digit (bool)
      # Param 5: mode (enum)
      "BC" => [1],
    }

    # ^A - Scalable/Bitmapped Font
    #
    # Param -1: font name (value: [A-Z0-9])
    # Param  0: field orientation (enum)
    # Param  1: character height in dots
    # Param  2: width in dots
    #
    # (Param -1 is part of the command name, it will not appear in ZplCommand's params)
    # ---
    # This must be done externally because the command is 1 char long, with the second
    # char being the font name, this means there are 36 2-char commands with the same
    # fonctionnality.
    #
    # So instead of:
    # AA: [....]
    # AB: [....]
    # AC: [....]
    # etc..
    # We simply generate it. Simple.
    (('A'..'Z').to_a.concat ('0'..'9').to_a).each do |font_name|
      COMMANDS_PARAM_INDEXES_TO_SCALE["A" + font_name] = [1, 2]
    end

    def self.dpi_scale zpl_content, from_dpi, to_dpi
      scale_ratio = to_dpi.to_f / from_dpi.to_f

      reader = ZplReader.new zpl_content
      scaled_zpl = StringIO.new

      puts "Scaling from #{ from_dpi } to #{ to_dpi } (scale_ratio: #{ scale_ratio })"

      reader.each_command do |cmd|
        scale_cmd!(cmd, scale_ratio)
        scaled_zpl << cmd.to_zpl_string

        puts
      end

      scaled_zpl.string
    end

    protected

    def self.cmd_need_scale? cmd
      !!COMMANDS_PARAM_INDEXES_TO_SCALE[cmd.name]
    end

    def self.scale_cmd! cmd, scale_ratio
      return unless cmd_need_scale? cmd

      puts "Scaling cmd named: #{ cmd.name } with params: #{ cmd.params.inspect }"

      cmd_params = cmd.params

      param_indexes_to_scale = COMMANDS_PARAM_INDEXES_TO_SCALE[cmd.name]
      param_indexes_to_scale.each do |param_index|

        puts "Param #{ param_index } before: #{ cmd_params[param_index] }"

        if (param_s = cmd_params[param_index]) && (param_i = param_to_i?(param_s))
          cmd_params[param_index] = (param_i * scale_ratio).to_i

          puts "    param_i: #{ param_i }"
          puts "    after: #{ cmd_params[param_index] }"
        end
      end
    end

    # Returns an integer converted from the string *param*, or nil if it cannot be
    # converted.
    def self.param_to_i? param
      begin
        Integer(param)
      rescue ArgumentError # raised when *param* string cannot be converted to Integer
        nil
      end
    end
  end

  def self.dpi_scale zpl_content, from_dpi, to_dpi
    Scaler.dpi_scale(zpl_content, from_dpi, to_dpi)
  end

end

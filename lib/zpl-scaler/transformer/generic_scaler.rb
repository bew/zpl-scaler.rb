require_relative './base_scaler'

module ZplScaler::Transformer
  # TODO: doc
  # It works by parsing ZPL commands, then edit the parameters of specific commands
  # to scale the coordinates to the new dpi
  class GenericScaler < BaseScaler
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

    def map_cmd(cmd)
      # TODO: cleanup (remove scale_cmd! indirection ?)
      scale_cmd!(cmd, scale_ratio)
      cmd
    end

    protected

    def cmd_need_scale?(cmd)
      !!COMMANDS_PARAM_INDEXES_TO_SCALE[cmd.name]
    end

    def scale_cmd!(cmd, scale_ratio)
      return unless cmd_need_scale? cmd

      cmd_params = cmd.params

      param_indexes_to_scale = COMMANDS_PARAM_INDEXES_TO_SCALE[cmd.name]
      param_indexes_to_scale.each do |param_index|
        if (param_s = cmd_params[param_index]) && (param_i = param_to_i?(param_s))
          cmd_params[param_index] = (param_i * scale_ratio).to_i
        end
      end
    end
  end
end

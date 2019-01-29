require_relative '../font'
require_relative '../reader'
require_relative './base_scaler'

module ZplScaler::Transformer

  # TODO: doc - Explain the algorithm used to scale bitmap font
  #
  # NOTE: will ONLY scale font commands
  # NOTE: doesn't support partial font cmd (yet)
  #       e.g: font with height but not width
  class FontScaler < BaseScaler
    # Supported font commands
    #
    # ^A - Scalable/Bitmapped Font
    #
    # Param -1: font name (value: [A-Z0-9])
    #    Note: This is part of the command name (second char), it will not appear in
    #    the command's params
    # Param  0: field orientation (enum)
    # Param  1: character height in dots
    # Param  2: character width in dots
    #
    #
    # ^CF - Change default Font
    #
    # Param 0: font name (value: [A-Z0-9])
    # Param 1: character height in dots
    # Param 2: character width in dots

    def initialize(ratio:, allow_font_change: false)
      super(ratio)
      @allow_font_change = allow_font_change
    end

    def map_cmd(raw_cmd)
      font, cmd_kind = font_and_kind_from_cmd?(raw_cmd)
      unless font
        # Unable to extract the font from the command, it is probably not
        # a font command, we don't touch it.
        return raw_cmd
      end

      given_height, given_width = extract_given_sizes(raw_cmd, cmd_kind)

      unless given_height && given_width
        # Either param height or width is not given, this is not supported.
        # Returning the same command.
        return raw_cmd
      end

      font_cmd = FontCommand.new(raw_cmd, cmd_kind, font, given_height, given_width)

      if font.scalable?
        scale_scalable_font(font_cmd)
      else
        scale_bitmap_font(font_cmd)
      end
    end

    protected

    # Helper data class with all the important data easily accessible for the conversion
    FontCommand = Struct.new(:raw_cmd, :kind, :font, :height, :width)

    def scale_scalable_font(font_cmd)
      scaled_height = scale_single_number(font_cmd.height)
      scaled_width = scale_single_number(font_cmd.width)

      make_cmd(font_cmd.raw_cmd, font_cmd.kind, font_cmd.font, scaled_height, scaled_width)
    end

    def scale_bitmap_font(font_cmd)
      given_font = font_cmd.font
      if @allow_font_change
        new_font = find_smallest_font_matching_size(given_font)
      end
      new_font ||= given_font

      norm_height, norm_width = given_font.normalize_size(
        height: font_cmd.height,
        width: font_cmd.width,
      )

      scaled_height = scale_single_number(norm_height)
      scaled_width = scale_single_number(norm_width)

      make_cmd(font_cmd.raw_cmd, font_cmd.kind, new_font, scaled_height, scaled_width)
    end

    private

    def extract_given_sizes(cmd, cmd_kind)
      # Format for ^CF: ^CFfont,height,width
      #    With `font`: the short font name [A-Z0-9]
      # Format for ^A: ^A#orient,height,width
      #    With #: the short font name [A-Z0-9]
      [param_to_i?(cmd.params[1]), param_to_i?(cmd.params[2])]
    end

    def find_smallest_font_matching_size(current_font)
      ZplScaler::Font.all.each do |font|
        next if current_font.base_size == font.base_size
        next unless current_font.type == font.type

        if (current_font.base_height % font.base_height) == 0 &&
            (current_font.base_width % font.base_width) == 0
          return font
        end
      end

      nil
    end

    def font_and_kind_from_cmd?(raw_cmd)
      if raw_cmd.name.start_with?('A')
        font_name = raw_cmd.name[1]
        cmd_kind = :set_font
      elsif raw_cmd.name == "CF"
        # Format: ^CFfont,height,width
        font_name = raw_cmd.params[0]
        cmd_kind = :change_default_font
      else
        return
      end
      [ZplScaler::Font.from_name?(font_name), cmd_kind]
    end

    def make_cmd(old_cmd, cmd_kind, new_font, height, width)
      case cmd_kind
      when :set_font
        ZplScaler::ZplCommand.new "A#{ new_font.name }", [old_cmd.params[0], height, width]
      when :change_default_font
        ZplScaler::ZplCommand.new "CF", [new_font.name, height, width]
      end
    end

  end
end

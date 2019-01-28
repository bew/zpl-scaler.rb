module ZplScaler

  class Font

    attr_accessor :name, :base_height, :base_width, :type

    def initialize(name:, base_height:, base_width:, type:, scalable: false)
      @name = name
      @base_height = base_height
      @base_width = base_width
      @type = type
      @scalable = scalable
    end

    def base_size
      [@base_height, @base_width]
    end

    def scalable?
      @scalable
    end

    # TODO: embed matrix here!
    # FONT    HxW (dots)         TYPE
    # A       9 X 5              U-L-D
    # B       11 X 7             U
    # C, D    18 X 10            U-L-D
    # E       42 x 20            OCR-B
    # F       26 x 13            U-L-D
    # G       60 x 40            U-L-D
    #
    # H       34 x 22            OCR-A
    # GS      24 x 24            SYMBOL
    # P       20 x 18            U-L-D
    # Q       28 x 24            U-L-D
    # R       35 x 31            U-L-D
    # S       40 x 35            U-L-D
    # T       48 x 42            U-L-D
    # U       59 x 53            U-L-D
    # V       80 x 71            U-L-D
    # 0       Default: 15 x 12   U-L-D

    AVAILABLE_FONTS = {
      "A" => Font.new(name: "A", base_height: 9, base_width: 5, type: :u_l_d),
      "B" => Font.new(name: "B", base_height: 11, base_width: 7, type: :u),
      "C" => Font.new(name: "C", base_height: 18, base_width: 10, type: :u_l_d),
      "D" => Font.new(name: "D", base_height: 18, base_width: 10, type: :u_l_d),
      "E" => Font.new(name: "E", base_height: 42, base_width: 20, type: :ocr_b),
      "F" => Font.new(name: "F", base_height: 26, base_width: 13, type: :u_l_d),
      "G" => Font.new(name: "G", base_height: 60, base_width: 40, type: :u_l_d),

      "0" => Font.new(name: "0", base_height: 15, base_width: 12, type: :u_l_d, scalable: true),
    }

    def self.all
      AVAILABLE_FONTS.values
    end

    def self.from_name?(font_name)
      AVAILABLE_FONTS[font_name]
    end

    # Normalize *height* and *width* to the font's height and width.
    def normalize_size(height:, width:)
      [
        normalize_single_size(height, ref_size: base_height),
        normalize_single_size(width, ref_size: base_width),
      ]
    end

    # Normalize *input_size* to be a multiple of *ref_size*.
    #
    # Example: (with ref_size = 10)
    #    input_size   normalized
    #        0           10
    #        7           10
    #       10           10
    #       11           20
    def normalize_single_size(input_size, ref_size:)
      if input_size == ref_size
        return ref_size
      else
        ((input_size / ref_size) + 1) * ref_size
      end
    end
  end

end

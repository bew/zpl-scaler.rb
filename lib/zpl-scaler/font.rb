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

    # Font matrix
    #
    # FONT    HxW (dots)         TYPE
    #
    ## Bitmap fonts
    # A       9 X 5              U-L-D
    # B       11 X 7             U
    # C, D    18 X 10            U-L-D
    # E       42 x 20            OCR-B
    # F       26 x 13            U-L-D
    # G       60 x 40            U-L-D
    # H       34 x 22            OCR-A
    # P       20 x 18            U-L-D
    # Q       28 x 24            U-L-D
    # R       35 x 31            U-L-D
    # S       40 x 35            U-L-D
    # T       48 x 42            U-L-D
    # U       59 x 53            U-L-D
    # V       80 x 71            U-L-D
    #
    ## Scalable font
    # 0       Default: 15 x 12   U-L-D
    #
    ## Unsupported font
    # GS      24 x 24            SYMBOL

    AVAILABLE_FONTS = {
      "A" => Font.new(name: "A", base_height: 9, base_width: 5, type: :u_l_d),
      "B" => Font.new(name: "B", base_height: 11, base_width: 7, type: :u),
      "C" => Font.new(name: "C", base_height: 18, base_width: 10, type: :u_l_d),
      "D" => Font.new(name: "D", base_height: 18, base_width: 10, type: :u_l_d),
      "E" => Font.new(name: "E", base_height: 42, base_width: 20, type: :ocr_b),
      "F" => Font.new(name: "F", base_height: 26, base_width: 13, type: :u_l_d),
      "G" => Font.new(name: "G", base_height: 60, base_width: 40, type: :u_l_d),
      "H" => Font.new(name: "H", base_height: 34, base_width: 22, type: :ocr_a),
      "P" => Font.new(name: "P", base_height: 20, base_width: 18, type: :u_l_d),
      "Q" => Font.new(name: "Q", base_height: 28, base_width: 24, type: :u_l_d),
      "R" => Font.new(name: "R", base_height: 35, base_width: 31, type: :u_l_d),
      "S" => Font.new(name: "S", base_height: 40, base_width: 35, type: :u_l_d),
      "T" => Font.new(name: "T", base_height: 48, base_width: 42, type: :u_l_d),
      "U" => Font.new(name: "U", base_height: 59, base_width: 53, type: :u_l_d),
      "V" => Font.new(name: "V", base_height: 80, base_width: 71, type: :u_l_d),
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

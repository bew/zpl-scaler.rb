RSpec.describe ZplScaler::Transformer::FontScaler do
  it "doesn't change non-font cmd" do
    non_font_zpl = "^MN42,10"

    tr = ZplScaler::Transformer::FontScaler.new(2.0)
    expect(tr.apply(non_font_zpl)).to eq non_font_zpl
  end

  it "1:1 scale normalize font sizes" do
    tr = ZplScaler::Transformer::FontScaler.new(1.0, allow_font_change: false)

    expect(tr.apply("^AA,2,3")).to eq "^AA,9,5"
    expect(tr.apply("^AA,9,5")).to eq "^AA,9,5"
    expect(tr.apply("^AA,18,5")).to eq "^AA,18,10"
    expect(tr.apply("^AAB,22,15")).to eq "^AAB,27,15"
    expect(tr.apply("^CFA,2,3")).to eq "^CFA,9,5"
  end

  ZplScaler::Font.all.reject(&:scalable?).each do |font|
    it "normalizes bitmap font '#{font.name}' to base HxW: #{font.base_height}x#{font.base_width}" do
      input_zpl = "^A#{font.name},1,1"
      normalized_font_zpl = "^A#{font.name},#{font.base_height},#{font.base_width}"

      tr = ZplScaler::Transformer::FontScaler.new(1.0, allow_font_change: false)
      expect(tr.apply(input_zpl)).to eq normalized_font_zpl
    end
  end

  ZplScaler::Font.all.select(&:scalable?).each do |font|
    it "doesn't normalize scalable font '#{font.name}' to base HxW: #{font.base_height}x#{font.base_width}" do
      input_zpl = "^A#{font.name},42,42"

      tr = ZplScaler::Transformer::FontScaler.new(1.0)
      expect(tr.apply(input_zpl)).to eq input_zpl
    end
  end

  it "doesn't change partial font cmd" do
    partial_font_cmd = "^CFD,,12" # font: D, height: unspecified, width: 12

    tr = ZplScaler::Transformer::FontScaler.new(1.0)
    expect(tr.apply(partial_font_cmd)).to eq partial_font_cmd
  end

  it "2:1 scale on scalable font" do
    # Font '0' is a scalable font

    code = "^A0,7,7"
    tr = ZplScaler::Transformer::FontScaler.new(2.0)
    expect(tr.apply(code)).to eq "^A0,14,14"
  end

  it "scaling changes to a smaller font when allowed" do
    code = "^AD,7,7"

    tr = ZplScaler::Transformer::FontScaler.new(1.5)
    expect(tr.apply(code)).to eq "^AA,27,15"
    # What happens here:
    # → 7,7 is normalized to 18,10
    # → Font D is changed to font A which can also be of size 18,10
    # → Height/Width sizes are scaled to 27,15
  end

  it "normalize sizes after scaling a bitmap font" do
    code = "^AD,7,7"

    tr = ZplScaler::Transformer::FontScaler.new(1.2)
    expect(tr.apply(code)).to eq "^AA,27,15"
    # What happens here:
    # → 7,7 is normalized to 18,10
    # → Font D is changed to font A which can also be of size 18,10
    # → Height/Width sizes are scaled to 21,11
    # → Height/Width sizes are normalized to 27,15
  end
end

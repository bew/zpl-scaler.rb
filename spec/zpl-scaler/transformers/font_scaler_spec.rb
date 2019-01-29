RSpec.describe ZplScaler::Transformer::FontScaler do
  it "doesn't change non-font cmd" do
    non_font_zpl = "^MN42,10"

    tr = ZplScaler::Transformer::FontScaler.new(ratio: 2.0)
    expect(tr.apply(non_font_zpl)).to eq non_font_zpl
  end

  it "1:1 scale normalize font sizes" do
    tr = ZplScaler::Transformer::FontScaler.new(ratio: 1.0)

    expect(tr.apply("^AA,2,3")).to eq "^AA,9,5"
    expect(tr.apply("^CFA,2,3")).to eq "^CFA,9,5"
  end

  ZplScaler::Font.all.reject(&:scalable?).each do |font|
    it "normalizes bitmap font '#{font.name}' to base HxW: #{font.base_height}x#{font.base_width}" do
      input_zpl = "^A#{font.name},1,1"
      normalized_font_zpl = "^A#{font.name},#{font.base_height},#{font.base_width}"

      tr = ZplScaler::Transformer::FontScaler.new(ratio: 1.0)
      expect(tr.apply(input_zpl)).to eq normalized_font_zpl
    end
  end

  ZplScaler::Font.all.select(&:scalable?).each do |font|
    it "doesn't normalize scalable font '#{font.name}' to base HxW: #{font.base_height}x#{font.base_width}" do
      input_zpl = "^A#{font.name},42,42"

      tr = ZplScaler::Transformer::FontScaler.new(ratio: 1.0)
      expect(tr.apply(input_zpl)).to eq input_zpl
    end
  end

  it "doesn't change partial font cmd" do
    partial_font_cmd = "^CFD,,12" # font: D, height: unspecified, width: 12

    tr = ZplScaler::Transformer::FontScaler.new(ratio: 1.0)
    expect(tr.apply(partial_font_cmd)).to eq partial_font_cmd
  end

  # TODO: test font change
end

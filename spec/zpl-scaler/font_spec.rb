RSpec.describe ZplScaler::Font do
  it "can differenciate scalable vs non-scalable font" do
    non_scalable_font = ZplScaler::Font.new name: "ZZZ", base_height: 42, base_width: 42, type: :foo
    expect(non_scalable_font.scalable?).to be false

    scalable_font = ZplScaler::Font.new name: "ZZZ", base_height: 42, base_width: 42, type: :foo, scalable: true
    expect(scalable_font.scalable?).to be true
  end

  it "normalizes given H/W to font's H/W" do
    font = ZplScaler::Font.new name: "ZZZ", base_height: 10, base_width: 10, type: :foo

    expect(font.normalize_size(height: 3, width: 7)).to eq [10, 10]
    expect(font.normalize_size(height: 10, width: 10)).to eq [10, 10]
  end

  it "normalizes with same multiplication factor for each H and W" do
    font = ZplScaler::Font.new name: "ZZZ", base_height: 15, base_width: 12, type: :foo

    expect(font.normalize_size(height: 16, width: 12)).to eq [30, 12]
    expect(font.normalize_size(height: 32, width: 43)).to eq [45, 48]
    expect(font.normalize_size(height: 30, width: 24)).to eq [30, 24]
  end
end

RSpec.describe ZplScaler::Font do
  it "normalizes given H/W to font's H/W" do
    font = ZplScaler::Font.new name: "ZZZ", base_height: 42, base_width: 42, type: :foo, scalable: false

    expect(font.normalize_size(height: 0, width: 23)).to eq [42, 42]
  end
end

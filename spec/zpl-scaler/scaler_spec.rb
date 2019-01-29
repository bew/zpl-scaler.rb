RSpec.describe ZplScaler do
  it "has a version number" do
    expect(ZplScaler::VERSION).not_to be nil
  end
end

RSpec.describe ZplScaler::Transformer::GenericScaler do
  it "1:1 scale gives same zpl code" do
    code = "^MN42,10^BCA,10"

    tr = ZplScaler::Transformer::GenericScaler.new(1.0)
    expect(tr.apply(code)).to eq code
  end

  def self.it_scales_by_2_cmd(cmd_name, input_args, scaled_args)
    it "scales 2:1 cmd ^#{ cmd_name }" do
      input_code = "^#{ cmd_name }#{ input_args }"
      scaled_code = "^#{ cmd_name }#{ scaled_args }"
      tr = ZplScaler::Transformer::GenericScaler.new(2.0)
      expect(tr.apply(input_code)).to eq scaled_code
    end
  end

  it_scales_by_2_cmd "MN", "1,1", "1,2"
  it_scales_by_2_cmd "BY", "1,1,1", "2,1,2"
  it_scales_by_2_cmd "FO", "1,1,1", "2,2,1"
  it_scales_by_2_cmd "B2", "1,1,1", "1,2,1"
  it_scales_by_2_cmd "GB", "1,1,1,1,1", "2,2,2,1,1"
  it_scales_by_2_cmd "BC", "1,1,1,1,1,1", "1,2,1,1,1,1"

  it "2:1 scale on multiple zpl cmd" do
    code = "^MN42,10^BC42,10"
    scaled_code = "^MN42,20^BC42,20"

    tr = ZplScaler::Transformer::GenericScaler.new(2.0)
    expect(tr.apply(code)).to eq scaled_code
  end
end

module Dummy
  class ExtandNameTransformer < ZplScaler::Transformer::Base
    def initialize(name_addition)
      @name_addition = name_addition
    end

    def map_cmd(cmd)
      cmd.name += @name_addition
      cmd
    end
  end
end

RSpec.describe ZplScaler::Transformer::Pipeline do
  it "does nothing when empty" do
    code = "^AA"

    pipeline = ZplScaler::Transformer::Pipeline.new([])
    expect(pipeline.apply(code)).to eq code
  end

  it "applies the transformers sequencially" do
    pipeline = ZplScaler::Transformer::Pipeline.new([
      Dummy::ExtandNameTransformer.new("foo"),
      Dummy::ExtandNameTransformer.new("bar"),
    ])

    cmd = ZplScaler::ZplCommand.new "AA"
    new_cmd = pipeline.map_cmd(cmd)
    expect(new_cmd.name).to eq "AAfoobar"
  end
end

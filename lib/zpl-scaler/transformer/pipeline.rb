require_relative './base'

module ZplScaler
  class Transformer::Pipeline < Transformer::Base

    def initialize(transformers)
      @transformers = transformers
    end

    def map_cmd(cmd)
      @transformers.each do |tr|
        new_cmd = tr.map_cmd(cmd)
        return unless new_cmd
        cmd = new_cmd
      end
      cmd
    end

  end
end

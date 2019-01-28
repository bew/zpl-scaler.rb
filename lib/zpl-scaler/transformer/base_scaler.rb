require_relative './base'

module ZplScaler

  class Transformer::BaseScaler < Transformer::Base

    def initialize(ratio)
      @scale_ratio = ratio.to_f
    end

    protected

    # Scale the given *number* by the configured ratio.
    def scale_single_number(number)
      (number * @scale_ratio).to_i
    end

  end

end

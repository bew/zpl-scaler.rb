require_relative './zpl-scaler/version'
require_relative './zpl-scaler/reader'
require_relative './zpl-scaler/scaler'

module ZplScaler

  def self.dpi_scale(zpl_content, from_dpi:, to_dpi:)
    scale_ratio = to_dpi.to_f / from_dpi.to_f

    Scaler.ratio_scale(zpl_content, scale_ratio)
  end

  def self.ratio_scale(zpl_content, scale_ratio)
    Scaler.ratio_scale(zpl_content, scale_ratio)
  end

end

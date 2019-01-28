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

  # Returns the list of unique commands used in the given ZPL.
  def self.uniq_commands(zpl_content)
    uniq_cmds = Set.new
    Reader.new(zpl_content).each_command do |cmd|
      uniq_cmds << cmd.name
    end
    uniq_cmds.to_a
  end

end

require_relative './zpl-scaler/version'
require_relative './zpl-scaler/reader'
require_relative './zpl-scaler/transformers'

module ZplScaler

  # Returns the list of unique commands used in the given ZPL.
  def self.uniq_commands(zpl_content)
    uniq_cmds = Set.new
    Reader.new(zpl_content).each_command do |cmd|
      uniq_cmds << cmd.name
    end
    uniq_cmds.to_a
  end

end

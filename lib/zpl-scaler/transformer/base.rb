require_relative '../reader'

module ZplScaler
  module Transformer
  end

  class Transformer::Base

    # TODO: doc
    def apply(zpl_code, strip_spaces: true)
      reader = ZplReader.new(zpl_code, strip_spaces: strip_spaces)
      transformed_zpl = StringIO.new
      reader.each_command do |cmd|
        if new_cmd = self.map_cmd(cmd)
          transformed_zpl << new_cmd.to_zpl_string
        end
      end

      transformed_zpl.string
    end

    # TODO: doc
    def map_cmd(cmd)
      cmd
    end

    protected

    # Returns an integer converted from the string *param*, or nil if it cannot be
    # converted or when the string is empty.
    def param_to_i?(param)
      begin
        Integer(param)
      rescue ArgumentError # raised when *param* string cannot be converted to Integer
        nil
      rescue TypeError # raised when *param* is nil
        nil
      end
    end
  end

end

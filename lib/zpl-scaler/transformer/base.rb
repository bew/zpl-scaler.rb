require_relative '../reader'

module ZplScaler
  module Transformer
  end

  class Transformer::Base

    # TODO: doc
    def apply(zpl_code)
      reader = ZplReader.new(zpl_code)
      transformed_zpl = StringIO.new

      while token = reader.next_token
        if token.is_a?(ZplCommand)
          # It's a command, transform it
          if new_cmd = self.map_cmd(token)
            transformed_zpl << new_cmd.to_zpl_string
          end
        else
          # Not a command, just append it
          transformed_zpl << token
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

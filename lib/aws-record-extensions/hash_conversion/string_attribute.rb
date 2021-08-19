module AwsRecordExtensions
  module HashConversion
    class StringAttribute < BaseAttribute
      def serialize(str_value)
        str_value.present? ? str_value.to_s : nil
      end

      def deserialize(str_value)
        str_value
      end
    end
  end
end

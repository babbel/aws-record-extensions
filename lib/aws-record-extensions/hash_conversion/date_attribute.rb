module AwsRecordExtensions
  module HashConversion
    class DateAttribute < BaseAttribute
      def serialize(date_value)
        date_value.present? ? date_value.iso8601 : nil
      end

      def deserialize(str_value)
        str_value.present? ? Date.parse(str_value) : nil
      end
    end
  end
end

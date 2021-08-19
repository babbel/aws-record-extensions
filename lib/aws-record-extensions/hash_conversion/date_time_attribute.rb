module AwsRecordExtensions
  module HashConversion
    class DateTimeAttribute < BaseAttribute
      def serialize(datetime_value)
        datetime_value.present? ? datetime_value.iso8601 : nil
      end

      def deserialize(str_value)
        str_value.present? ? Time.parse(str_value) : nil
      end
    end
  end
end

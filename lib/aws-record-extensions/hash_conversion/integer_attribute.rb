module AwsRecordExtensions
  module HashConversion
    class IntegerAttribute < BaseAttribute
      def serialize(integer_value)
        integer_value.present? ? integer_value.to_i : nil
      end

      def deserialize(integer_value)
        integer_value.present? ? integer_value.to_i : nil
      end
    end
  end
end

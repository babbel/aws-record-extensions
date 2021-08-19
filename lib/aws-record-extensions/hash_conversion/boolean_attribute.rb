module AwsRecordExtensions
  module HashConversion
    class BooleanAttribute < BaseAttribute
      def serialize(value)
        to_bool(value)
      end

      def deserialize(value)
        to_bool(value)
      end

      private

      def to_bool(obj)
        obj.to_s.downcase == "true"
      end
    end
  end
end

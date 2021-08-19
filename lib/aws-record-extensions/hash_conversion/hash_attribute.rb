module AwsRecordExtensions
  module HashConversion
    class HashAttribute < BaseAttribute
      def serialize(value)
        return unless hash?(value)

        value.to_h.deep_stringify_keys
      end

      def deserialize(value)
        return unless hash?(value)

        value.to_h
      end

      private

      def hash?(value)
        value && value.respond_to?(:to_h)
      end
    end
  end
end

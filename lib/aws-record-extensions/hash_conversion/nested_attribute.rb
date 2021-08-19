module AwsRecordExtensions
  module HashConversion
    class NestedAttribute < BaseAttribute
      def initialize(name, nested_class, serializer)
        super(name)
        @nested_class = nested_class
        @serializer = serializer
      end

      def serialize(obj)
        return nil unless obj.present?

        @serializer.to_h(obj)
      end

      def deserialize(obj)
        return nil unless obj.present?
        return obj if obj.is_a?(@nested_class)

        @serializer.from_h(obj)
      end
    end
  end
end

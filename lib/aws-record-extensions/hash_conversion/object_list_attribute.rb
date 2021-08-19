module AwsRecordExtensions
  module HashConversion
    class ObjectListAttribute < BaseAttribute
      def initialize(name, nested_class, serializer)
        super(name)
        @nested_class = nested_class
        @serializer = serializer
      end

      def serialize(items)
        return unless items.respond_to? :map

        items.map { |item| @serializer.to_h(item) }
      end

      def deserialize(items)
        return unless items.respond_to? :map

        items.map do |item|
          if (item.is_a?(@nested_class))
            item
          else
            @serializer.from_h(item)
          end
        end
      end
    end
  end
end

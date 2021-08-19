module AwsRecordExtensions
  module HashConversion
    module ObjectSerializers
      class ListSerializer
        def initialize(item_serializer:)
          @item_serializer = item_serializer
        end

        def from_primitive_type(hashes)
          raise TypecastError, "expected an Array, but received #{hashes.inspect}" unless hashes.is_a?(Array)

          hashes.map do |hash|
            @item_serializer.from_primitive_type(hash)
          end
        end
        alias_method :from_a, :from_primitive_type

        def to_primitive_type(objects)
          raise TypecastError, "expected an Array, but received #{objects.inspect}" unless objects.is_a?(Array)

          objects.map do |object|
            @item_serializer.to_primitive_type(object)
          end
        end
        alias_method :to_a, :to_primitive_type
      end
    end
  end
end

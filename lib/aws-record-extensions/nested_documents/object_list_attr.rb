module AwsRecordExtensions
  module NestedDocuments
    module ObjectListAttr
      extend ActiveSupport::Concern

      class_methods do
        def object_list_attr(
          name,
          type_cast:,
          # By default assume that type from type_cast has
          # a pair of methods from_h/to_h:
          serializer: AwsRecordExtensions::HashConversion::ObjectSerializers::ListSerializer.new(
            item_serializer: AwsRecordExtensions::HashConversion::ObjectSerializers::SelfHashSerializer.new(type_cast)
          ),
          **opts
        )
          marshaller = ObjectListMarshaller.new(
            type_cast: type_cast,
            serializer: serializer
          )
          attr(name, marshaller, { dynamodb_type: 'L' }.merge(opts))

          AwsRecordExtensions::HashConversion::ObjectSerializers::TypecastOnSetAttribute.extend_attr_setter_with_typecast(name, marshaller)

          define_method("#{name}?") { send(name).present? }
        end
      end
    end

    class ObjectListMarshaller
      def initialize(type_cast:, serializer:)
        @type_cast = type_cast
        @serializer = serializer
      end

      def type_cast(raw_value)
        case raw_value
        when nil
          nil
        when Array
          typecast_items(raw_value)
        else
          if raw_value.respond_to?(:to_a)
            typecast_items(raw_value.to_a)
          else
            msg = "Don't know how to make #{raw_value} of type #{raw_value.class} into an array!"
            raise AwsRecordExtensions::HashConversion::ObjectSerializers::TypecastError, msg
          end
        end
      end

      def serialize(raw_value)
        items = type_cast(raw_value)

        items && @serializer.to_primitive_type(items)
      end

      private

      def typecast_items(array)
        @serializer.from_primitive_type(array)
      end
    end
  end
end

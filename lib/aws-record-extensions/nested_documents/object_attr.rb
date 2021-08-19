module AwsRecordExtensions
  module NestedDocuments
    module ObjectAttr
      extend ActiveSupport::Concern

      class_methods do
        def object_attr(
          name,
          type_cast:,
          # By default assume that type from type_cast has
          # a pair of methods from_h/to_h:
          serializer: AwsRecordExtensions::HashConversion::ObjectSerializers::SelfHashSerializer.new(type_cast),
          **opts
        )
          marshaller = ObjectMarshaller.new(
            type_cast: type_cast,
            serializer: serializer
          )
          attr(name, marshaller, { dynamodb_type: 'M' }.merge(opts))

          AwsRecordExtensions::HashConversion::ObjectSerializers::TypecastOnSetAttribute.extend_attr_setter_with_typecast(name, marshaller)

          define_method("#{name}?") { send(name).present? }
        end
      end
    end

    class ObjectMarshaller
      def initialize(type_cast:, serializer:)
        @type_cast = type_cast
        @serializer = serializer
      end

      def type_cast(raw_value)
        if raw_value.nil?
          nil
        elsif raw_value.is_a?(@type_cast)
          raw_value
        else
          @serializer.from_primitive_type(raw_value)
        end
      end

      def serialize(raw_value)
        obj = type_cast(raw_value)

        obj && @serializer.to_primitive_type(obj)
      end
    end
  end
end

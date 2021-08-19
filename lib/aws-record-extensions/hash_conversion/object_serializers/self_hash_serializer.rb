module AwsRecordExtensions
  module HashConversion
    module ObjectSerializers
      class SelfHashSerializer
        def initialize(type_cast)
          @type_cast = type_cast
        end

        def from_primitive_type(hash)
          return hash if hash.is_a?(@type_cast)

          raise TypecastError, "expected a Hash, but received #{hash.inspect}" unless hash.is_a?(Hash)

          @type_cast.from_h(hash)
        end
        alias_method :from_h, :from_primitive_type

        def to_primitive_type(object)
          return object if object.is_a?(Hash)

          raise TypecastError, "expected a #{@type_cast.class.name}, but received #{object.inspect}" unless object.is_a?(@type_cast)

          object.to_h
        end
        alias_method :to_h, :to_primitive_type
      end
    end
  end
end

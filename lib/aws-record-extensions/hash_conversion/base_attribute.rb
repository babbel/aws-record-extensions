module AwsRecordExtensions
  module HashConversion
    class BaseAttribute
      def initialize(name)
        @name = name.to_s
      end

      def add_to_hash(object, hash)
        value = object.public_send(@name)
        hash[@name] = serialize(value)
      end

      def extract_from_hash(hash, object)
        value = hash[@name] || hash[@name.to_sym]
        deserialized_value = deserialize(value)
        object.public_send("#{@name}=", deserialized_value)
      end

      private

      def serialize
        raise 'Not implemented'
      end

      def deserialize
        raise 'Not implemented'
      end
    end
  end
end

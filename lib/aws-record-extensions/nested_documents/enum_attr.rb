module AwsRecordExtensions
  module NestedDocuments
    class EnumError < StandardError; end

    module EnumAttr
      extend ActiveSupport::Concern

      class_methods do
        def enum_attr(name, possible_values:, **opts)
          unless possible_values.include?(opts.fetch(:default_value))
            raise EnumError, "default_value must be one of the possible_values"
          end

          attr(name, EnumMarshaller.new(
            possible_values: possible_values
          ), { dynamodb_type: 'S' }.merge(opts))
        end
      end
    end

    class EnumMarshaller < Aws::Record::Marshalers::StringMarshaler
      def initialize(possible_values:)
        @possible_values = possible_values
        super()
      end

      def serialize(raw_value)
        value = super(raw_value)

        unless @possible_values.include?(value)
          msg = "expected one of: #{@possible_values}, got #{value}"
          raise EnumError, msg
        end

        value
      end
    end
  end
end

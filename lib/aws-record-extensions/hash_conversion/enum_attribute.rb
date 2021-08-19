module AwsRecordExtensions
  module HashConversion
    class EnumError < StandardError; end

    class EnumAttribute < StringAttribute
      def initialize(name,  possible_values:, default_value:)
        unless possible_values.include?(default_value)
          raise EnumError, "default_value must be one of the possible_values"
        end
        @possible_values = possible_values
        @default_value = default_value

        super(name)
      end

      def serialize(str_value)
        return @default_value if str_value.nil?
        check_value!(str_value)

        super(str_value)
      end

      def deserialize(str_value)
        return @default_value if str_value.nil?
        check_value!(str_value)

        super(str_value)
      end

      private

      def check_value!(str_value)
        return if @possible_values.include?(str_value)

        message = "expected one of: #{@possible_values}, got #{str_value}"
        raise EnumError, message
      end
    end
  end
end

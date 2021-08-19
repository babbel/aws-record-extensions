require 'money'

module AwsRecordExtensions
  module NestedDocuments
    class MoneyError < StandardError; end

    module MoneyAttr
      extend ActiveSupport::Concern

      def self.included(base)
        base.include AwsRecordExtensions::NestedDocuments::ObjectAttr
      end

      class_methods do
        def money_attr(name, opts = {})
          object_attr(name, {
            type_cast: Money,
            serializer: AwsRecordExtensions::HashConversion::ObjectSerializers::MoneySerializer
          }.merge(opts))
        end
      end
    end
  end
end

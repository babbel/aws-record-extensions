require 'active_support/concern'

module AwsRecordExtensions
  module FindAndCreate
    extend ActiveSupport::Concern

    class_methods do
      def create!(attributes)
        item = new(attributes)
        item.created_at = DateTime.current.utc
        item.save!
        item
      end

      def find!(attributes)
        item = find(attributes)
        raise RecordNotFound, attributes if item.nil?

        item
      end

      def consistent_find(attributes)
        find_with_opts(
          key: attributes,
          consistent_read: true
        )
      end

      def find_or_create(attributes)
        Retryable.with_context(:dynamodb_write) do
          # https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ReadConsistency.html
          item = consistent_find(attributes)
          return item unless item.nil?

          create!(attributes)
        end
      end
    end
  end
end

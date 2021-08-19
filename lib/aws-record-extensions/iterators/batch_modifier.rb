require_relative 'batch_scan'

module AwsRecordExtensions
  module Iterators
    class BatchModifier
      def initialize(aws_record_model)
        @aws_record_model = aws_record_model
      end

      delegate :dynamodb_client, :table_name, to: :@aws_record_model

      def modify_in_batches(opts = {}, &block)
        BatchScan.new(@aws_record_model).scan_in_batches(opts) do |items|
          migrate_scanned_page(items, &block)
        end
      end

      private

      BATCH_WRITE_ITEMS_LIMIT = 25 # https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_BatchWriteItem.html

      def migrate_scanned_page(items, &block)
        migrated_items = items.map(&block).compact
        log_update_on_the_page(migrated_items.count)
        return unless migrated_items.count > 0

        migrated_items.each_slice(BATCH_WRITE_ITEMS_LIMIT).each_with_index do |batch_of_migrated_items, batch_num|
          update_all_items(batch_of_migrated_items)
        end
      end

      def update_all_items(items)
        payload = {
          table_name => items.map do |item|
            {
              put_request: {
                item: item
              }
            }
          end
        }
        # There is no batch 'update' method, only batch 'put', thus we need to read all attributes during 'scan'
        dynamodb_client.batch_write_item(request_items: payload)
      end

      def log_update_on_the_page(items_count)
        puts "Writing items back to DynamoDB. Items to be updated: #{items_count}"
      end
    end
  end
end

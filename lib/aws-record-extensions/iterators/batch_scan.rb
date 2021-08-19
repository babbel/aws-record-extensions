module AwsRecordExtensions
  module Iterators
    class BatchScan
      def initialize(aws_record_model)
        @aws_record_model = aws_record_model
      end

      delegate :dynamodb_client, :table_name, to: :@aws_record_model

      DEFAULT_BATCH_SIZE = 1000

      def scan_in_batches(opts = {}, start_key_name = nil, start_key_value = nil, &block)
        scan_options = { table_name: table_name, limit: DEFAULT_BATCH_SIZE }.merge(opts)
        scan_options[:exclusive_start_key] = { start_key_name => start_key_value } if start_key_value

        items = dynamodb_client.scan(scan_options)

        iterate_pages(items, &block)
      end

      private

      def iterate_pages(items)
        pagenum = 0
        items.each_page do |page|
          pagenum += 1
          log_page(pagenum, page)

          yield page.items
        end
      end

      def log_page(pagenum, page)
        puts "Scan page: #{pagenum}, items: #{page.count}, last_evaluated_key: #{page.last_evaluated_key}"
      end
    end
  end
end

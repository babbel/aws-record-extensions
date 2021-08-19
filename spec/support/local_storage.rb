require 'aws-record'

module LocalStorage
  def self.create_tables!
    require_relative 'test_model'

    migration = Aws::Record::TableMigration.new(TestModel, client: TestModel.dynamodb_client)
    migration.create!(
      provisioned_throughput: {
        read_capacity_units: 1,
        write_capacity_units: 1
      }
    )
    migration.wait_until_available
  rescue Aws::DynamoDB::Errors::ResourceInUseException
    puts "DynamoDB table #{TestModel.table_name} already exists"
  end

  def self.drop_tables!
    require_relative 'test_model'

    test_migration = Aws::Record::TableMigration.new(TestModel, client: TestModel.dynamodb_client)
    test_migration.delete!
  end
end

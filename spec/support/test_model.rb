require_relative 'test_nested_model'

class TestModel
  include Aws::Record
  include AwsRecordExtensions::FindAndCreate
  include AwsRecordExtensions::NestedDocuments

  configure_client(DynamodbConfig.client_options)
  set_table_name("test-model")

  string_attr :merchant_reference, hash_key: true
  datetime_attr :created_at

  enum_attr :state, possible_values: [ "unpaid", "paid" ], default_value: "unpaid"

  money_attr :price

  object_attr :nested, type_cast: TestNestedModel

  object_list_attr :nested_list, type_cast: TestNestedModel
  object_list_attr :prices, type_cast: Money,
    serializer: AwsRecordExtensions::HashConversion::ObjectSerializers::ListSerializer.new(
      item_serializer: AwsRecordExtensions::HashConversion::ObjectSerializers::MoneySerializer)
end

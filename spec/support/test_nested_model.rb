require_relative 'test_subnested_model'

class TestNestedModel
  include ActiveModel::Model
  include AwsRecordExtensions::HashConversion

  nested_attr_accessor :subnested, attr_class: TestSubnestedModel
  string_attr_accessor :id
  nested_attr_accessor :price, attr_class: Money, hash_serializer: ObjectSerializers::MoneySerializer
end

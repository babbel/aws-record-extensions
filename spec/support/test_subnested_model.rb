class TestSubnestedModel
  include ActiveModel::Model
  include AwsRecordExtensions::HashConversion

  string_attr_accessor :id
  nested_attr_accessor :price, attr_class: Money, hash_serializer: ObjectSerializers::MoneySerializer
end

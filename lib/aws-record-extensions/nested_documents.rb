require_relative 'nested_documents/enum_attr'
require_relative 'nested_documents/money_attr'
require_relative 'nested_documents/object_attr'
require_relative 'nested_documents/object_list_attr'

module AwsRecordExtensions
  module NestedDocuments
    def self.included(base)
      base.include AwsRecordExtensions::NestedDocuments::EnumAttr
      base.include AwsRecordExtensions::NestedDocuments::MoneyAttr
      base.include AwsRecordExtensions::NestedDocuments::ObjectAttr
      base.include AwsRecordExtensions::NestedDocuments::ObjectListAttr
    end
  end
end

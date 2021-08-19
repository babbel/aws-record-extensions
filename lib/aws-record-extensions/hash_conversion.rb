require 'active_support/concern'
require 'active_support/hash_with_indifferent_access'
require_relative 'hash_conversion/object_serializers/list_serializer'
require_relative 'hash_conversion/object_serializers/typecast_error'
require_relative 'hash_conversion/object_serializers/typecast_on_set_attribute'
require_relative 'hash_conversion/object_serializers/hash_guard'
require_relative 'hash_conversion/object_serializers/money_serializer'
require_relative 'hash_conversion/object_serializers/self_hash_serializer'
require_relative 'hash_conversion/base_attribute'
require_relative 'hash_conversion/string_attribute'
require_relative 'hash_conversion/object_list_attribute'
require_relative 'hash_conversion/boolean_attribute'
require_relative 'hash_conversion/date_attribute'
require_relative 'hash_conversion/date_time_attribute'
require_relative 'hash_conversion/enum_attribute'
require_relative 'hash_conversion/hash_attribute'
require_relative 'hash_conversion/integer_attribute'
require_relative 'hash_conversion/nested_attribute'

module AwsRecordExtensions
  module HashConversion
    extend ActiveSupport::Concern

    class_methods do
      def string_attr_accessor(name)
        hashing_attributes << StringAttribute.new(name)
        attr_accessor(name)
      end

      def integer_attr_accessor(name)
        hashing_attributes << IntegerAttribute.new(name)
        attr_accessor(name)
      end

      def date_attr_accessor(name)
        hashing_attributes << DateAttribute.new(name)
        attr_accessor(name)
      end

      def datetime_attr_accessor(name)
        hashing_attributes << DateTimeAttribute.new(name)
        attr_accessor(name)
      end

      def bool_attr_accessor(name)
        hashing_attributes << BooleanAttribute.new(name)
        attr_accessor(name)
      end

      def enum_attr_accessor(name, possible_values:, default_value:)
        hashing_attributes << EnumAttribute.new(name, possible_values: possible_values, default_value: default_value)
        attr_accessor(name)
      end

      def hash_attr_accessor(name, default_value: nil)
        hashing_attributes << HashAttribute.new(name)

        attr_writer(name)

        define_method(name) do
          value = instance_variable_get("@#{name}".to_sym)
          if !value && default_value
            value = default_value
            instance_variable_set("@#{name}".to_sym, value)
          end
          value.try(:with_indifferent_access)
        end
      end

      def nested_attr_accessor(name, attr_class:, hash_serializer: ObjectSerializers::SelfHashSerializer.new(attr_class))
        hashing_attributes << NestedAttribute.new(name, attr_class, hash_serializer)

        attr_accessor(name)

        define_method("#{name}?") { send(name).present? }
      end

      def object_list_attr_accessor(name, attr_class:, hash_serializer: ObjectSerializers::SelfHashSerializer.new(attr_class))
        hashing_attributes << ObjectListAttribute.new(name, attr_class, hash_serializer)

        attr_accessor(name)

        define_method("#{name}?") { send(name).present? }
      end

      def money_attr_accessor(name)
        nested_attr_accessor(name, attr_class: Money, hash_serializer: ObjectSerializers::MoneySerializer)
      end

      def from_h(hash)
        return nil if hash.nil?

        obj = new()
        hashing_attributes.each do |hashing_attribute|
          hashing_attribute.extract_from_hash(hash, obj)
        end
        obj
      end

      def hashing_attributes
        @hashing_attributes ||= []
      end
    end

    def ==(other_object)
      return false unless other_object.respond_to? :to_h
      self.to_h == other_object.to_h
    end

    def to_h
      result = {}
      self.class.hashing_attributes.each do |hashing_attribute|
        hashing_attribute.add_to_hash(self, result)
      end
      result
    end
  end
end

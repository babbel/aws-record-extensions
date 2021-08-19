# This extension avoids the case when Aws::Record sets the value without
# type-casting it and then does typecast every time we call #get_attribute
# In this case #get_attribute worked well only with primitive types.
# For more complex objects like we have in object_attr and object_list_attr
# it always returned a new freshly constructed value.
# This module allows to modify 'set_attribute' behaviour for only the chosen
# attributes which we control (object_attr, object_list_attr etc.), but to
# keep the existing behaviour for all attributes that are provided by the gem
# in order to avoid having more dependencies than needed and changing the
# behaviour globally for all users of this patch.
# By doing typecasting before we #set_attribute, we make sure that internally
# Aws::Record always stores complex objects and when typecast is happening
# inside #get_attribute, it does not recreate the complex objects we have, but
# instead just returns an instance. This way we achieve a memoisation of a
# nested objects.
# Storing the value as a typecast value is safe because every time Aws::Record
# stores anything into a database, it first calls #serialize on the value. And
# serialize will always do typecast first (yet another typecast we don't really
# want).
# Dirty tracking also works well, because it just compares values using #== and
# for our objects we override #== method to compare internal structure, not
# to compare by the identity of an object instance. This is another safeguard.
# Without this change dirty tracking still works, but it may trigger a false
# positives when object was not changed really, but was marked as dirty.
# We just made it work more reliable by overriding #==.
module AwsRecordExtensions
  module HashConversion
    module ObjectSerializers
      module TypecastOnSetAttribute
        def self.extend_attr_setter_with_typecast(extend_for_name, marshaller)
          dynamic_module = Module.new do
            define_method(:set_attribute) do |attr_name, value|
              value_to_set = if attr_name == extend_for_name
                               @model_attributes.attribute_for(attr_name).type_cast(value)
                             else
                               value
                             end

              super(attr_name, value_to_set)
            end
          end

          ::Aws::Record::ItemData.prepend(dynamic_module)
        end
      end
    end
  end
end

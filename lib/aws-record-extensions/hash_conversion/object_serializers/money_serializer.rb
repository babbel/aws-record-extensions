require 'money'

module AwsRecordExtensions
  module HashConversion
    module ObjectSerializers
      # This serializer can work with object_attr as an Object serializer
      # and with nested_attr_accessor as Hash serializer (this one is more type strict)
      class MoneySerializer
        class << self
          def from_primitive_type(hash)
            return hash if hash.is_a?(Money)

            safe_hash = ensure_money_hash(hash)
            return unless safe_hash

            ensure_int_amount!(safe_hash[:amount])

            Money.new(safe_hash["amount"].to_i, safe_hash["currency"].to_s)
          end
          alias_method :from_h, :from_primitive_type

          def to_primitive_type(money)
            return ensure_money_hash(money) if money.is_a?(Hash)

            {
              "amount" => money.cents,
              "currency" => money.currency.iso_code
            }
          end
          alias_method :to_h, :to_primitive_type

          private

          def ensure_money_hash(hash)
            HashGuard.ensure_hash_structure!(hash, "amount", "currency")
          end

          def ensure_int_amount!(amount)
            unless amount.respond_to?(:to_i)
              raise TypecastError,
                "Amount should be an integer (cents), but was #{amount}"
            end
          end
        end
      end
    end
  end
end

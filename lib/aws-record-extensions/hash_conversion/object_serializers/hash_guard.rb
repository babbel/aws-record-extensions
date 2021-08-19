require "active_support/core_ext/hash/indifferent_access"

module AwsRecordExtensions
  module HashConversion
    module ObjectSerializers
      module HashGuard
        class << self
          def ensure_hash_structure!(input_hash, *required_keys)
            typecast_error!(input_hash, required_keys) unless input_hash.is_a?(Hash)

            safe_hash = input_hash.with_indifferent_access.slice(*required_keys)
            return nil if safe_hash.values.all?(&:nil?) # We need this until we have {amount: nil, currency: nil} in the DB

            required_keys.each do |key|
              typecast_error!(input_hash, required_keys) unless safe_hash[key].present?
            end

            safe_hash
          end

          private

          def typecast_error!(hash, required_keys)
            raise ::AwsRecordExtensions::HashConversion::ObjectSerializers::TypecastError,
              "Expected a Hash with #{required_keys} attributes, got #{hash.inspect}"
          end
        end
      end
    end
  end
end

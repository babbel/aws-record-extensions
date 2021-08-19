module Factories
  module TestModel
    class << self

      def build(attributes_overrides = {})
        attrs = default_attributes.merge(attributes_overrides)
        ::TestModel.new(attrs)
      end

      def create(attributes_overrides = {})
        order = build(attributes_overrides)
        order.save!
        order
      end

      private

      def default_attributes
        {
          merchant_reference: SecureRandom.hex(16),
          created_at: Time.now
        }
      end

    end
  end
end

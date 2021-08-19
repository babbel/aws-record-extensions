require 'spec_helper'

RSpec.describe AwsRecordExtensions::NestedDocuments::ObjectListAttr do
  let(:model) { Factories::TestModel.build() }
  let(:saved_model) { TestModel.find!(merchant_reference: model.merchant_reference) }

  context "for complex types which we control" do
    context "when setting nested attribute with correctly structured hash value" do
      let(:nested_data_to_store) do
        {
          "id" => "nested_id",
          "subnested" => {
            "id" => "subnested_id"
          }
        }
      end

      it "stores payment method information into DB" do
        model.nested_list = [nested_data_to_store]

        model.save!

        expect(saved_model.nested_list.length).to eq 1
        expect(saved_model.nested_list.first.id).to eq "nested_id"
        expect(saved_model.nested_list.first.subnested.id).to eq "subnested_id"
      end

      it 'allows to change the values in the list' do
        model.nested_list = [nested_data_to_store]
        model.save!

        expect {
          saved_model.nested_list.first.id = "override_id"
          saved_model.save!
        }.to change{ saved_model.reload!.nested_list.first.id }.to "override_id"
      end

      it 'allows to change the values of a subnested objects in the list' do
        model.nested_list = [nested_data_to_store]
        model.save!

        expect {
          saved_model.nested_list.first.subnested.id = "override_sub_id"
          saved_model.save!
        }.to change{ saved_model.reload!.nested_list.first.subnested.id }.to "override_sub_id"
      end

      context "when we pass several items" do
        let(:more_nested_data_to_store) do
          {
            "id" => "more_nested_id",
          }
        end

        it "stores all of them" do
          model.nested_list = [nested_data_to_store, more_nested_data_to_store]

          model.save!

          expect(saved_model.nested_list.map(&:id)).to match_array ["nested_id", "more_nested_id"]
        end
      end
    end

    context "when setting submodel with correct typecast value" do
      let(:nested_data_to_store) do
        TestNestedModel.new(
          id: "nested2_id",
          subnested: TestSubnestedModel.new(id: "subnested2_id")
        )
      end

      it "stores payment method information into DB" do
        model.nested_list = [nested_data_to_store]

        model.save!

        expect(saved_model.nested_list.first.id).to eq "nested2_id"
        expect(saved_model.nested_list.first.subnested.id).to eq "subnested2_id"
      end
    end

    context "when setting submodel with an object which can transform into Array" do
      module Arrayish
        def self.to_a
          [{"id" => "arrayish_id"}]
        end
      end

      it "converts the object to array and stores the value" do
        model.nested_list = Arrayish

        model.save!

        expect(saved_model.nested_list.first.id).to eq "arrayish_id"
      end
    end

    context "when setting submodel with nil value" do
      it "stores nil value" do
        model.nested = nil

        model.save!

        expect(saved_model.nested).to eq nil
      end
    end

    context "when setting submodel with PaymentMethod value" do
      it "raise an error payment method information into DB" do
        expect {
          model.nested = 10_00

          model.save!
        }.to raise_error(AwsRecordExtensions::HashConversion::ObjectSerializers::TypecastError)
      end
    end
  end

  context "for types which we are not controlling" do
    context "when assigning object of a specified type" do
      let(:price_to_store) { Money.new(10_00, "USD") }

      it "stores price information into DB" do
        model.prices = [price_to_store]

        model.save!

        expect(saved_model.prices.first).to eq price_to_store
      end
    end

    context "when assigning nil value" do
      it "stores nil value" do
        model.prices = nil

        model.save!

        expect(saved_model.prices).to eq nil
      end
    end

    context "when assigning basic type which can be converted into object using serializer" do
      it "stores money data" do
        model.prices = [{ amount: "2000", currency: "RUB" }]

        model.save!

        expect(saved_model.prices.first).to eq Money.new(20_00, "RUB")
      end
    end

    context "when non-array object is assigned" do
      it "raise an error price information into DB" do
        expect {
          model.prices = Money.new(10_00, "USD")

          model.save!
        }.to raise_error(AwsRecordExtensions::HashConversion::ObjectSerializers::TypecastError)
      end
    end

    context "when assigning a type which does not support the conversion" do
      it "raise an error price information into DB" do
        expect {
          model.prices = [10_00]

          model.save!
        }.to raise_error(AwsRecordExtensions::HashConversion::ObjectSerializers::TypecastError)
      end
    end
  end
end

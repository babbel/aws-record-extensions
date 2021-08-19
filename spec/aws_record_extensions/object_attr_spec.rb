require 'spec_helper'

RSpec.describe AwsRecordExtensions::NestedDocuments::ObjectAttr do
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

      it "stores data into DB" do
        model.nested = nested_data_to_store

        model.save!

        expect(saved_model.nested.id).to eq "nested_id"
        expect(saved_model.nested.subnested.id).to eq "subnested_id"
      end

      it 'defines a *? method' do
        expect { model.nested = nested_data_to_store }.to change {
          model.nested? }.from(false).to(true)
      end

      it "stores data into DB after type assignment" do
        model.nested = TestNestedModel.from_h(nested_data_to_store)

        model.save!

        expect(saved_model.nested.id).to eq "nested_id"
        expect(saved_model.nested.subnested.id).to eq "subnested_id"
      end

      it 'allows to change the values of a nested objects' do
        model.nested = nested_data_to_store
        model.save!

        expect {
          model.reload!.nested.id = "override_id"
          model.save!
        }.to change{ saved_model.reload!.nested.id }.to "override_id"
      end

      it 'allows to change the values of a subnested objects' do
        model.nested = nested_data_to_store
        model.save!

        expect {
          saved_model.nested.subnested.id = "override_sub_id"
          saved_model.save!
        }.to change{ saved_model.reload!.nested.subnested.id }.to "override_sub_id"
      end
    end

    context "when updating payment method with correct typecast value" do
      let(:nested_data_to_store) do
        TestNestedModel.new(
          id: "nested2_id",
          subnested: TestSubnestedModel.new(id: "subnested2_id")
        )
      end

      it "stores data into DB" do
        model.nested = nested_data_to_store

        model.save!

        expect(saved_model.nested.id).to eq "nested2_id"
        expect(saved_model.nested.subnested.id).to eq "subnested2_id"
      end

      it 'allow to override the nested values' do
        model.nested = nested_data_to_store
        model.save!

        expect {
          saved_model.nested = TestNestedModel.from_h(id: "override_id2")
          saved_model.save!
        }.to change{ saved_model.reload!.nested.id }.to "override_id2"
      end
    end

    context "when updating payment method with nil value" do
      it "stores nil value" do
        model.nested = nil

        model.save!

        expect(saved_model.nested).to eq nil
      end
    end

    context "when updating payment method not with PaymentMethod value" do
      it "raise an error data into DB" do
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
        model.price = price_to_store

        model.save!

        expect(saved_model.price).to eq price_to_store
      end
    end

    context "when assigning nil value" do
      it "stores nil value" do
        model.price = nil

        model.save!

        expect(saved_model.price).to eq nil
      end
    end

    context "when assigning basic type which can be converted into object using serializer" do
      it "stores money data" do
        model.price = { amount: "2000", currency: "RUB" }

        model.save!

        expect(saved_model.price).to eq Money.new(20_00, "RUB")
      end
    end

    context "when assigning a type which does not support the conversion" do
      it "raise an error price information into DB" do
        expect {
          model.price = 10_00

          model.save!
        }.to raise_error(AwsRecordExtensions::HashConversion::ObjectSerializers::TypecastError)
      end
    end

    context "when this type should be cast for nested object" do
      context "when correctly formatted hash is provided" do
        let(:nested_price) do
          {
            "price" => { amount: "3000", currency: "CHF" }
          }
        end

        it "stores price information into DB" do
          model.nested = nested_price

          model.save!

          expect(saved_model.nested.price).to eq Money.new(30_00, "CHF")
        end
      end

      context "when typecast object is provided" do
        let(:price_to_store) { Money.new(40_00, "CAD") }
        let(:nested_price) do
          {
            "price" => price_to_store
          }
        end

        it "stores price information into DB" do
          model.nested = nested_price

          model.save!

          expect(saved_model.nested.price).to eq price_to_store
        end
      end

      context "when nil is provided" do
        let(:nested_price) do
          {
            "price" => nil
          }
        end

        it "stores nil" do
          model.nested = nested_price

          model.save!

          expect(saved_model.nested.price).to eq nil
        end
      end

      context "when empty object is provided" do
        let(:nested_price) do
          {
            "price" => { amount: nil, currency: nil }
          }
        end

        it "stores nil" do
          model.nested = nested_price

          model.save!

          expect(saved_model.nested.price).to eq nil
        end
      end

      context "when type without conversion rules is provided" do
        let(:nested_price) do
          {
            "price" => "20.00 EUR"
          }
        end

        it "raise an error data into DB" do
          expect {
            model.nested = 10_00

            model.save!
          }.to raise_error(AwsRecordExtensions::HashConversion::ObjectSerializers::TypecastError)
        end
      end

      context "for deeper nesting levels" do
        let(:nested_price) do
          {
            "subnested" => {
              "price" => { amount: "5000", currency: "USD" }
            }
          }
        end

        it "stores price information into DB" do
          model.nested = nested_price

          model.save!

          expect(saved_model.nested.subnested.price).to eq Money.new(50_00, "USD")
        end
      end
    end
  end
end

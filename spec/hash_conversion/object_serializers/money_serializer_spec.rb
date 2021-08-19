require 'spec_helper'

RSpec.describe AwsRecordExtensions::HashConversion::ObjectSerializers::MoneySerializer do

  describe ".from_primitive_type" do
    context "when supplied a hash with known structure with symbol keys" do
      it "returns a Money object with correctly set fields" do
        result = described_class.from_primitive_type(
          amount: "300",
          currency: "EUR"
        )

        expect(result).to eq(Money.new(300, "EUR"))
      end
    end

    context "when supplied a hash with known structure with string keys" do
      it "returns a Money object with correctly set fields" do
        result = described_class.from_primitive_type(
          "amount" => "300",
          "currency" => "EUR"
        )

        expect(result).to eq(Money.new(300, "EUR"))
      end
    end

    context "when supplied a hash without required fields" do
      it "throws an exception" do
        expect {
          described_class.from_primitive_type(
            amouououaunt: 100,
            currency: "EUR"
          )
        }.to raise_error(AwsRecordExtensions::HashConversion::ObjectSerializers::TypecastError)
      end
    end

    context "when supplied a hash with wrong types of the attributes" do
      context "with wrong amount" do
        it "throws an exception" do
          expect {
            described_class.from_primitive_type(
              amount: { amount_nested: "asdf" },
              currency: "EUR"
            )
          }.to raise_error(AwsRecordExtensions::HashConversion::ObjectSerializers::TypecastError)
        end
      end

      context "with wrong currency" do
        it "throws an exception" do
          expect {
            described_class.from_primitive_type(
              amount: "100",
              currency: 3
            )
          }.to raise_error(Money::Currency::UnknownCurrency)
        end
      end
    end

  end

  describe ".to_primitive_type" do
    it "returns a Hash object with all money fields" do
      result = described_class.to_primitive_type(Money.new(125, "USD"))

      expect(result).to eq("amount" => 125, "currency" => "USD")
    end
  end

end

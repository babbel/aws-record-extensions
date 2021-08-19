require "spec_helper"

RSpec.describe AwsRecordExtensions::HashConversion::EnumAttribute do

  class TestEnum
    include ActiveModel::Model
    include AwsRecordExtensions::HashConversion

    enum_attr_accessor :test_item, possible_values: ['days', 'months'], default_value: 'days'
  end

  describe "serialization" do
    context "when value is not specified" do
      let(:hash_example) { TestEnum.new() }

      it "sets default value" do
        expect(hash_example.to_h).to eq({ "test_item" => 'days' })
      end
    end

    context "when value is nil" do
      let(:hash_example) { TestEnum.new(test_item: nil) }

      it "sets default value" do
        expect(hash_example.to_h).to eq({ "test_item" => 'days' })
      end
    end

    context "when value is from not supported subset" do
      let(:hash_example) { TestEnum.new(test_item: 'wrong') }

      it "raise an error" do
        expect{ hash_example.to_h }.to raise_error(AwsRecordExtensions::HashConversion::EnumError)
      end
    end

    context "when value is from a supported subset" do
      let(:hash_example) { TestEnum.new(test_item: "months") }

      it "sets the value with stringified keys" do
        expect(hash_example.to_h).to eq({ "test_item" => "months" })
      end
    end
  end

  describe "deserialization" do
    context "when value is not specified" do
      it "returns default value" do
        expect(TestEnum.from_h({}).test_item).to eq('days')
      end
    end

    context "when value is nil" do
      it "returns default value" do
        expect(TestEnum.from_h({ "test_item" => nil }).test_item).to eq('days')
      end
    end

    context "when value is not from the allowed subset" do
      it "raise an error" do
        expect{ TestEnum.from_h({ "test_item" => "hello" }) }.to raise_error(AwsRecordExtensions::HashConversion::EnumError)
      end
    end

    context "when value is from the allowed subset" do
      it "returns the value" do
        expect(TestEnum.from_h({ "test_item" => "months" }).test_item).to eq("months")
      end
    end
  end
end

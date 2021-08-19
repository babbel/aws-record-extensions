require "spec_helper"

RSpec.describe AwsRecordExtensions::HashConversion::HashAttribute do

  class TestHash
    include ActiveModel::Model
    include AwsRecordExtensions::HashConversion

    hash_attr_accessor :test_item
  end

  describe "serialization" do
    context "when value is nil" do
      let(:hash_example) { TestHash.new(test_item: nil) }

      it "sets value as nil" do
        expect(hash_example.to_h).to eq({ "test_item" => nil })
      end
    end

    context "when value is not a hash" do
      let(:hash_example) { TestHash.new(test_item: 1) }

      it "sets value as nil" do
        expect(hash_example.to_h).to eq({ "test_item" => nil })
      end
    end

    context "when value is a hash" do
      let(:hash_value) do { "a" => { b: 123 }} end
      let(:hash_example) { TestHash.new(test_item: hash_value) }

      it "sets the value with stringified keys" do
        expected_result = { "a" => { "b" => 123 }}
        expect(hash_example.to_h).to eq({ "test_item" => expected_result})
      end
    end
  end

  describe "deserialization" do
    context "when value is nil" do
      it "sets value as nil" do
        expect(TestHash.from_h({ "test_item" => nil }).test_item).to eq(nil)
      end
    end

    context "when value is not a hash" do
      it "sets it to nil" do
        expect(TestHash.from_h({ "test_item" => true }).test_item).to eq(nil)
      end
    end

    context "when value is a hash" do
      it "sets value with stringified keys" do
        hash_value = { a: {"b" => false }}
        expect(TestHash.from_h({ "test_item" => hash_value }).test_item).to eq("a" => {"b" => false})
      end
    end
  end
end

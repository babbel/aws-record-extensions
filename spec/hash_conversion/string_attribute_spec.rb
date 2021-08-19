require "spec_helper"

RSpec.describe AwsRecordExtensions::HashConversion::StringAttribute do

  class TestStr
    include ActiveModel::Model
    include AwsRecordExtensions::HashConversion

    string_attr_accessor :name
  end

  describe "serialization" do
    context "when value is nil" do
      let(:str_example) { TestStr.new(name: nil) }

      it "sets value as nil" do
        expect(str_example.to_h).to eq({ "name" => nil })
      end
    end

    context "when value is empty string" do
      let(:str_example) { TestStr.new(name: "") }

      it "sets value as nil, because dynamo does not allow empty strings in nested objects" do
        expect(str_example.to_h).to eq({ "name" => nil })
      end
    end

    context "when value is normal string" do
      let(:str_example) { TestStr.new(name: "111") }

      it "sets the value without modification" do
        expect(str_example.to_h).to eq({ "name" => "111" })
      end
    end
  end

  describe "deserialization" do
    context "when value is nil" do
      it "sets value as nil" do
        expect(TestStr.from_h({ "name" => nil }).name).to eq(nil)
      end
    end

    context "when value is a string" do
      it "sets it without modification" do
        expect(TestStr.from_h({ "name" => "222" }).name).to eq("222")
      end
    end
  end
end

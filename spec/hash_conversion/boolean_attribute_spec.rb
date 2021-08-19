require "spec_helper"


RSpec.describe AwsRecordExtensions::HashConversion::BooleanAttribute do
  class TestBool
    include ActiveModel::Model
    include AwsRecordExtensions::HashConversion

    bool_attr_accessor :is_active
  end

  describe "serialization" do
    context "when value is nil" do
      let(:bool_example) { TestBool.new(is_active: nil) }

      it "sets value as false" do
        expect(bool_example.to_h).to eq({ "is_active" => false })
      end
    end

    context "when value is not boolean" do
      let(:bool_example) { TestBool.new(is_active: 1) }

      it "sets value as false" do
        expect(bool_example.to_h).to eq({ "is_active" => false })
      end
    end

    context "when value is a bool true" do
      let(:bool_example) { TestBool.new(is_active: true) }

      it "sets the value without modification" do
        expect(bool_example.to_h).to eq({ "is_active" => true })
      end
    end

    context "when value is a string true" do
      let(:bool_example) { TestBool.new(is_active: "true") }

      it "sets the value without modification" do
        expect(bool_example.to_h).to eq({ "is_active" => true })
      end
    end
  end

  describe "deserialization" do
    context "when value is nil" do
      it "sets value as false" do
        expect(TestBool.from_h({ "is_active" => nil }).is_active).to eq(false)
      end
    end

    context "when value is a boolean" do
      it "sets it without modification" do
        expect(TestBool.from_h({ "is_active" => true }).is_active).to eq(true)
      end
    end

    context "when value is a string" do
      it "sets value as integer" do
        expect(TestBool.from_h({ "is_active" => "true" }).is_active).to eq(true)
      end
    end
  end
end

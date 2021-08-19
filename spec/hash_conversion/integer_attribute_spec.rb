require "spec_helper"

RSpec.describe AwsRecordExtensions::HashConversion::IntegerAttribute do

  class TestInt
    include ActiveModel::Model
    include AwsRecordExtensions::HashConversion

    integer_attr_accessor :duration
  end

  describe "serialization" do
    context "when value is nil" do
      let(:int_example) { TestInt.new(duration: nil) }

      it "sets value as nil" do
        expect(int_example.to_h).to eq({ "duration" => nil })
      end
    end

    context "when value is 0" do
      let(:int_example) { TestInt.new(duration: 0) }

      it "sets value as 0" do
        expect(int_example.to_h).to eq({ "duration" => 0 })
      end
    end

    context "when value is a normal integer" do
      let(:int_example) { TestInt.new(duration: 7) }

      it "sets the value without modification" do
        expect(int_example.to_h).to eq({ "duration" => 7 })
      end
    end
  end

  describe "deserialization" do
    context "when value is nil" do
      it "sets value as nil" do
        expect(TestInt.from_h({ "duration" => nil }).duration).to eq(nil)
      end
    end

    context "when value is an integer" do
      it "sets it without modification" do
        expect(TestInt.from_h({ "duration" => 7 }).duration).to eq(7)
      end
    end

    context "when value is a string" do
      it "sets value as integer" do
        expect(TestInt.from_h({ "duration" => "7" }).duration).to eq(7)
      end
    end
  end
end

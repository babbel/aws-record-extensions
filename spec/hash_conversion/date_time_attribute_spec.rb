require "spec_helper"

RSpec.describe AwsRecordExtensions::HashConversion::DateTimeAttribute do

  class TestTime
    include ActiveModel::Model
    include AwsRecordExtensions::HashConversion

    datetime_attr_accessor :time
  end

  describe "serialization" do
    context "when value is nil" do
      let(:str_example) { TestTime.new(time: nil) }

      it "sets value as nil" do
        expect(str_example.to_h).to eq({ "time" => nil })
      end
    end

    context "when value is Time" do
      let(:str_example) { TestTime.new(time: Time.new(2029, 01, 31, 10, 30, 15)) }

      it "sets the value without modification" do
        expect(str_example.to_h["time"]).to match("2029-01-31T10:30:15")
      end
    end
  end

  describe "deserialization" do
    context "when value is nil" do
      it "sets value as nil" do
        expect(TestTime.from_h({ "time" => nil }).time).to eq(nil)
      end
    end

    context "when value is a string" do
      it "sets it without modification" do
        expect(TestTime.from_h({ "time" => "2030-12-31T10:30:15" }).time).to eq(Time.new(2030, 12, 31, 10, 30, 15))
      end
    end
  end
end

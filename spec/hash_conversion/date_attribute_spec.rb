require "spec_helper"

RSpec.describe AwsRecordExtensions::HashConversion::DateAttribute do

  class TestDate
    include ActiveModel::Model
    include AwsRecordExtensions::HashConversion

    date_attr_accessor :date
  end

  describe "serialization" do
    context "when value is nil" do
      let(:str_example) { TestDate.new(date: nil) }

      it "sets value as nil" do
        expect(str_example.to_h).to eq({ "date" => nil })
      end
    end

    context "when value is Date" do
      let(:str_example) { TestDate.new(date: Date.new(2029, 01, 31)) }

      it "sets the value without modification" do
        expect(str_example.to_h).to eq({ "date" => "2029-01-31" })
      end
    end
  end

  describe "deserialization" do
    context "when value is nil" do
      it "sets value as nil" do
        expect(TestDate.from_h({ "date" => nil }).date).to eq(nil)
      end
    end

    context "when value is a string" do
      it "sets it without modification" do
        expect(TestDate.from_h({ "date" => "2030-12-31" }).date).to eq(Date.new(2030, 12, 31))
      end
    end
  end
end

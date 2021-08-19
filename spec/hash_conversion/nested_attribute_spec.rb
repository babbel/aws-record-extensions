require "spec_helper"

RSpec.describe AwsRecordExtensions::HashConversion::NestedAttribute do

  class TestStr
    include ActiveModel::Model
    include AwsRecordExtensions::HashConversion

    string_attr_accessor :name
  end

  class TestNested
    include ActiveModel::Model
    include AwsRecordExtensions::HashConversion

    nested_attr_accessor :nested, attr_class: TestStr
  end

  let(:str_example) { TestStr.new(name: "strval") }

  describe "serialization" do
    context "when value is nil" do
      let(:nested_example) { TestNested.new(nested: nil) }

      it "sets value as nil" do
        expect(nested_example.to_h).to eq({ "nested" => nil })
      end
    end

    context "when value is nested object with its own serialization" do
      let(:nested_example) { TestNested.new(nested: str_example) }

      it "sets the value to hash returned by nested object" do
        expect(nested_example.to_h).to eq({ "nested" => { "name" => "strval" }})
      end
    end
  end

  describe "deserialization" do
    context "when value is nil" do
      it "sets value as nil" do
        expect(TestNested.from_h({ "nested" => nil }).nested).to eq(nil)
      end
    end

    context "when value is a string" do
      it "sets it without modification" do
        result = TestNested.from_h({ "nested" => { "name" => "strval" }})
        expect(result.nested.name).to eq("strval")
      end
    end
  end
end

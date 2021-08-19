require "spec_helper"

RSpec.describe AwsRecordExtensions::HashConversion::ObjectListAttribute do

  class TestNestedInList
    include ActiveModel::Model
    include AwsRecordExtensions::HashConversion

    string_attr_accessor :name
  end

  class TestList
    include ActiveModel::Model
    include AwsRecordExtensions::HashConversion

    object_list_attr_accessor :items, attr_class: TestNestedInList
  end

  describe "serialization" do
    context "when value is nil" do
      let(:list_example) { TestList.new(items: nil) }

      it "sets value as nil" do
        expect(list_example.to_h).to eq({ "items" => nil })
      end
    end

    context "when value is empty array" do
      let(:list_example) { TestList.new(items: []) }

      it "sets value as empty array" do
        expect(list_example.to_h).to eq({ "items" => [] })
      end
    end

    context "when value is a list of objects" do
      let(:list_example) do
        TestList.new(
          items: [
            TestNestedInList.new(name: "a"),
            TestNestedInList.new(name: "bb")
          ]
        )
      end

      it "sets the value to hash returned by nested object" do
        expect(list_example.to_h).to eq(
          "items" => [
            { "name" => "a" },
            { "name" => "bb" }
          ]
        )
      end
    end
  end

  describe "deserialization" do
    context "when value is nil" do
      it "sets value as nil" do
        expect(TestList.from_h({ "items" => nil }).items).to eq(nil)
      end
    end

    context "when value is an empty array" do
      it "sets it without modification" do
        expect(TestList.from_h({ "items" => [] }).items).to eq([])
      end
    end

    context "when value is a list of objects" do
      it "sets value as integer" do
        result = TestList.from_h(
          "items" => [
            { "name" => "a" },
            { "name" => "bb" }
          ]
        )

        expect(result.items.map(&:name)).to match_array(["a", "bb"])
      end
    end
  end
end

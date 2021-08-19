require "spec_helper"

RSpec.describe AwsRecordExtensions::HashConversion do

  class TestStr
    include ActiveModel::Model
    include AwsRecordExtensions::HashConversion

    string_attr_accessor :name
  end

  let(:str_example) { TestStr.new(name: "abc") }

  describe "#to_h" do
    it "serialize object to hash" do
      expect(str_example.to_h).to eq({ "name" => "abc" })
    end
  end

  describe ".from_h" do
    it "deserialize object from hash with string keys" do
      expect(TestStr.from_h({ "name" => "abc" }).name).to eq("abc")
    end

    it "deserialize object from hash with symbol keys" do
      expect(TestStr.from_h({name: "abc" }).name).to eq("abc")
    end

    context "when object is not present" do
      it "returns nil" do
        expect(TestStr.from_h(nil)).to be_nil
      end
    end
  end

  describe "#==" do
    let(:conversible_object) { TestStr.from_h({ "name" => "abc" }) }

    it 'is not equal to not hasheable objects' do
      expect(conversible_object).not_to eq(11)
    end

    it 'compares to real Hashes' do
      expect(conversible_object).to eq("name" => "abc")
    end

    it 'compares to self' do
      expect(conversible_object).to eq(conversible_object)
    end

    it 'compares basing on hash representation of an object' do
      module TestStrEquivalent
        def self.to_h
          { "name" => "abc" }
        end
      end

      expect(conversible_object).to eq(TestStrEquivalent)
    end
  end
end

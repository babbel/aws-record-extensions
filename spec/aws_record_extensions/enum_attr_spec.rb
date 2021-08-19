require 'spec_helper'

RSpec.describe AwsRecordExtensions::NestedDocuments::EnumAttr do
  let(:model) { Factories::TestModel.build() }
  let(:saved_model) { TestModel.find!(merchant_reference: model.merchant_reference) }

  context "when enum value is not specified" do
    it "returns default value of enum" do
      expect(model.state).to eq "unpaid"
    end
  end

  context "when value is changed to supported value" do
    it "updates the DB" do
      model.state = "paid"

      model.save!

      expect(saved_model.state).to eq "paid"
    end
  end

  context "when value is changed to unsopported value" do
    it "raises an error" do
      model.state = "unsupported value"

      expect {
        model.save!
      }.to raise_error(AwsRecordExtensions::NestedDocuments::EnumError)
    end
  end
end

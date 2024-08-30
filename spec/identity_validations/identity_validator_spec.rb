# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IdentityValidations::IdentityValidator do
  class TestModel
    include ActiveModel::Validations
    attr_accessor :an_attribute
  end
  let(:model) { TestModel.new }
  
  it 'throws an error due to being abstract' do
    expect {model.validates_with IdentityValidations::IdentityValidator}.
      to raise_error(NotImplementedError, 'IdentityValidator#validator is an abstract method and needs to be overridden')
  end

  describe 'a simple inheriting validator' do
    class SimpleValidator < IdentityValidations::IdentityValidator
      def validate(record)
        get_attribute(record).present?
      end
    end

    it 'throws an error without a bad attribute specified' do
      model.an_attribute = "something"
      expect {model.validates_with SimpleValidator, attribute: :invalid_attribute}.
        to raise_error(ArgumentError, "IdentityValidator: attribute 'invalid_attribute' not found in class TestModel")
    end

    it 'will validate when passed an attribute' do
      model.an_attribute = "something"
      model.validates_with SimpleValidator, attirbute: :an_attribute
      expect(model.errors).to be_blank
      expect(model.errors.messages).to be_blank
    end
  end
end

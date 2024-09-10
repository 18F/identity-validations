# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IdentityValidations::IdentityValidator do
  class TestModel
    include ActiveModel::Validations
    attr_accessor :an_attribute
  end
  let(:model) { TestModel.new }
  
  it 'throws an error due to being abstract' do
    expect { model.validates_with IdentityValidations::IdentityValidator }.
      to raise_error(NotImplementedError, 'IdentityValidator#validate is an abstract method that needs to be overridden')
  end

  describe 'a simple inheriting validator' do
    class SimpleValidator < IdentityValidations::IdentityValidator
      def validate(record)
        get_attribute(record).present?
      end
    end

    describe "invoked via ActiveModel's #validates_with" do
      it 'throws an error when an invalid attribute is specified' do
        model.an_attribute = "something"
        expect {model.validates_with SimpleValidator, attribute: :invalid_attribute}.
          to raise_error(ArgumentError, "IdentityValidator: attribute 'invalid_attribute' not found in class TestModel")
      end

      it 'will validate when passed an attribute' do
        model.an_attribute = "something"
        model.validates_with SimpleValidator, attribute: :an_attribute
        expect(model.errors).to be_blank
        expect(model.errors.messages).to be_blank
      end

      it 'throws an error when not given an attribute' do
        model.an_attribute = "something"
        expect { model.validates_with SimpleValidator }.
          to raise_error(ArgumentError, "IdentityValidator: can't validate TestModel, no attribute specified")
      end
    end

    describe "#validate" do
      it 'throws an error when not given an attribute' do
        model.an_attribute = "something"

        # In theory, we can call SimpleValidator.new with arguments to pass in an option.
        # However, this is an ability inherited from the Rails parent class.
        # This inherited option argument is more likely to be changed by Rails than the `validates_with`
        # option argument, so ideally our usage and tests shouldn't rely on that Rails implementation detail

        expect {SimpleValidator.new.validate(model)}.
          to raise_error(ArgumentError, "IdentityValidator: can't validate TestModel, no attribute specified")
      end
    end
  end
end

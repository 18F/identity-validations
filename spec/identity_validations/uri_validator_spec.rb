# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IdentityValidations::IdentityValidator do
  class TestModel
    include ActiveModel::Validations
    attr_accessor :test_url
  end

  let(:model) { TestModel.new }

  it 'allows blank' do
    model.validates_with IdentityValidations::UriValidator, attribute: :test_url
    model.test_url = ''
    expect(model.errors).to be_blank
    expect(model.errors.messages).to be_blank
  end
  
  it 'allows a standard URL' do
    model.test_url = 'https://www.login.gov'
    model.validates_with IdentityValidations::UriValidator, attribute: :test_url
    expect(model.errors).to be_blank
    expect(model.errors.messages).to be_blank
  end

  it 'rejects some words' do
    model.test_url = 'some words'
    model.validates_with IdentityValidations::UriValidator, attribute: :test_url
    expect(model.errors).to_not be_blank
    expect(model.errors.messages).to eq({test_url: ['is invalid']})
  end

  it 'raises an error if the attribute is not specified' do
    expect {model.validates_with IdentityValidations::UriValidator}.
      to raise_error(ArgumentError, 'UriValidator called without an `attribute:` option to validate')
  end
end

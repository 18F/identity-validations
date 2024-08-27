# frozen_string_literal: true

require 'identity_validations/version'
require 'identity_validations/uri_validator'
require 'identity_validations/allowed_redirects_validator'
require 'identity_validations/are_x509_validator'
require 'identity_validations/service_provider_validation'

module IdentityValidations
  class Error < StandardError; end
  # Your code goes here...
end

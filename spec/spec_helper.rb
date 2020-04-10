# frozen_string_literal: true

require 'bundler/setup'
require 'byebug'
require 'identity_validations'
require 'ostruct'
require 'active_model'
require 'active_model/validations'
require 'active_record'
require 'active_record/validations'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

class TestServiceProvider
  include ::ActiveModel::Model
  include ::ActiveModel::Validations
  include ::ActiveRecord::Validations
  include IdentityValidations::ServiceProviderValidation

  attr_accessor :friendly_name, :issuer, :ial, :redirect_uris, :failure_to_proof_url, :push_notification_url, :saml_client_cert

  def initialize(**args)
    super
  end

  def new_record?
    true
  end

  def self._reflect_on_association(foo)
    false
  end
end

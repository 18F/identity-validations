# frozen_string_literal: true

require 'identity_validations'
require 'active_model'
require 'active_model/validations'
require 'active_record'
require 'active_record/validations'

module IdentityValidations
  class TestServiceProvider
    include ::ActiveModel::Model
    include ::ActiveModel::Validations
    include ::ActiveRecord::Validations
    include IdentityValidations::ServiceProviderValidation

    attr_accessor :friendly_name, :issuer, :ial, :redirect_uris, :failure_to_proof_url, :push_notification_url, :saml_client_cert

    def initialize(**args)
      super
    end

    # needed to get validations to run
    def new_record?
      true
    end

    # needed to get validations to run
    def self._reflect_on_association(_foo)
      false
    end
  end
end

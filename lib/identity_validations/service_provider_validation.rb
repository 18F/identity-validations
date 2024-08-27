# frozen_string_literal: true

require 'openssl'
require 'active_model'

module IdentityValidations
  # Applies consistent validations to service providers
  module ServiceProviderValidation
    def self.included(base)
      base.class_eval do
        validates :friendly_name, presence: true
        validates :issuer, presence: true, uniqueness: true
        validates :issuer, format: { with: ISSUER_FORMAT_REGEXP }, on: :create
        validates :ial, inclusion: { in: [1, 2] }, allow_nil: true

        validates :redirect_uris, allow_blank: true,  :'identity_validations/allowed_redirects' => true
        validates :failure_to_proof_url, allow_blank: true, :'identity_validations/uri' => true
        validates :push_notification_url, allow_blank: true, :'identity_validations/uri' => true
        validates :acs_url, allow_blank: true, :'identity_validations/uri' => true
        validates :assertion_consumer_logout_service_url, allow_blank: true, :'identity_validations/uri' => true
        validates :certs, allow_blank: true, :'identity_validations/are_x509' => true
      end
    end

    private

    # Note: We no longer have strong validation of the issuer string.
    #         We used to require that the issuer matched this format:
    #         'urn:gov:gsa:<protocol>:2.0.profiles:sp:sso:<agency>:<app name>'
    #         However, it was too restrictive for many COTS applications. Now,
    #         we just enforce uniqueness, without whitespace.
    ISSUER_FORMAT_REGEXP = /\A[\S]+\z/.freeze
  end
end

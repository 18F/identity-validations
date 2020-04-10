# frozen_string_literal: true
require 'openssl'

module IdentityValidations
  # Applies consistent validations to service providers
  module ServiceProviderValidation
    def self.included(base)
      base.class_eval do
        validates :friendly_name, presence: true
        validates :issuer, presence: true, uniqueness: true
        validates :issuer, format: { with: ISSUER_FORMAT_REGEXP }, on: :create
        validates :ial, inclusion: { in: [1, 2] }, allow_nil: true

        validate :redirect_uris_are_parsable
        validate :failure_to_proof_url_is_parsable
        validate :push_notification_url_is_parsable
        validate :saml_client_cert_is_x509_if_present
      end
    end

    private

    # Note: We no longer have strong validation of the issuer string.
    #         We used to require that the issuer matched this format:
    #         'urn:gov:gsa:<protocol>:2.0.profiles:sp:sso:<agency>:<app name>'
    #         However, it was too restrictive for many COTS applications. Now,
    #         we just enforce uniqueness, without whitespace.
    ISSUER_FORMAT_REGEXP = /\A[\S]+\z/.freeze

    def redirect_uris_are_parsable
      return if redirect_uris.blank?

      redirect_uris.each do |uri|
        next if uri_valid?(uri)

        errors.add(:redirect_uris, :invalid)
        break
      end
    end

    def failure_to_proof_url_is_parsable
      return if failure_to_proof_url.blank?

      errors.add(:failure_to_proof_url, :invalid) unless uri_valid?(failure_to_proof_url)
    end

    def push_notification_url_is_parsable
      return if push_notification_url.blank?

      errors.add(:push_notification_url, :invalid) unless uri_valid?(push_notification_url)
    end

    def saml_client_cert_is_x509_if_present
      dashboard = respond_to?(:saml_client_cert)
      certificate = get_certificate(dashboard)
      return if certificate.blank?

      begin
        OpenSSL::X509::Certificate.new(certificate)
      rescue OpenSSL::X509::CertificateError
        flag_cert_invalid(dashboard)
      end
    end

    def uri_valid?(uri)
      parsed_uri = URI.parse(uri)
      return false unless parsed_uri.scheme.present?
      /(https?|file)/ =~ parsed_uri.scheme ? parsed_uri.host.present? : true
    rescue URI::BadURIError, URI::InvalidURIError
      false
    end

    def get_certificate(dashboard)
      if dashboard
        saml_client_cert
      else
        file = Rails.root.join('certs', 'sp', "#{cert}.crt")

        File.read(file) if file.exist?
      end
    end

    def flag_cert_invalid(dashboard)
      if dashboard
        errors.add(:saml_client_cert, :invalid)
      else
        errors.add(:cert, :invalid)
      end
    end
  end
end

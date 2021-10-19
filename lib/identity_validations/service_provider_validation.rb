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
        validate :certs_are_x509_if_present
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
        next if uri_valid?(uri) || uri_custom_scheme_only?(uri)

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

    def certs_are_x509_if_present
      Array(certs).each do |cert|
        content = cert_content(cert)
        next if content.blank?

        OpenSSL::X509::Certificate.new(content)
      rescue OpenSSL::X509::CertificateError => e
        errors.add(:certs, "#{cert} is invalid - #{e.message}")
      end
    end

    def uri_valid?(uri)
      parsed_uri = URI.parse(uri)
      return false if unsupported_uri?(parsed_uri)

      web_uri?(parsed_uri) || native_uri?(parsed_uri) || custom_uri?(parsed_uri)
    rescue URI::BadURIError, URI::InvalidURIError
      false
    end

    def uri_custom_scheme_only?(uri)
      parsed_uri = URI.parse(uri)
      return false if unsupported_uri?(parsed_uri)
      return false if /\Ahttps?/ =~ parsed_uri.scheme

      parsed_uri.scheme.present?
    rescue URI::BadURIError, URI::InvalidURIError
      false
    end

    def unsupported_uri?(uri)
      !!(/\A(s?ftp|ldaps?|file|mailto)/ =~ uri.scheme)
    end

    def web_uri?(uri)
      !!(/\Ahttps?/ =~ uri.scheme && uri.host.present?)
    end

    # Not a strict definition of native uri, but a catch-all
    # to ensure we have the bare minimum
    def native_uri?(uri)
      uri.scheme.present? && uri.path.present?
    end

    def custom_uri?(uri)
      uri.scheme.present? && uri.host.present?
    end

    def cert_content(cert)
      all_printable_chars = /\A[[:print:]]+\Z/.match?(cert)

      if all_printable_chars && defined?(Rails)
        file = Rails.root.join('certs', 'sp', "#{cert}.crt")
        File.exist?(file) && file.read
      else
        cert
      end
    end
  end
end

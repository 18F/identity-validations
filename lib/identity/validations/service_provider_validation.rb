require 'active_support/concern'

module Identity
  module Validations
    module ServiceProviderValidation
      extend ActiveSupport::Concern

      included do
        validates :friendly_name, presence: true
        validates :issuer, presence: true, uniqueness: true
        validates :issuer, format: { with: ISSUER_FORMAT_REGEXP }, on: :create
        validates :ial, inclusion: { in: [1, 2] }, allow_nil: true

        validate :redirect_uris_are_parsable
        validate :failure_to_proof_url_is_parsable
        validate :saml_client_cert_is_x509_if_present
      end

      private

      # Note: We no longer have strong validation of the issuer string. We used to
      #         require that the issuer matched this format:
      #         'urn:gov:gsa:<protocol>:2.0.profiles:sp:sso:<agency>:<app name>'
      #         However, it was too restrictive for many COTS applications. Now,
      #         we just enforce uniqueness, without whitespace.
      ISSUER_FORMAT_REGEXP = /\A[\S]+\z/

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

      def saml_client_cert_is_x509_if_present
        return if saml_client_cert.blank?

        begin
          OpenSSL::X509::Certificate.new(saml_client_cert)
        rescue OpenSSL::X509::CertificateError
          errors.add(:saml_client_cert, :invalid)
        end
      end

      def uri_valid?(uri)
        parsed_uri = URI.parse(uri)
        parsed_uri.scheme.present? && parsed_uri.host.present?
      rescue URI::BadURIError, URI::InvalidURIError
        false
      end
    end
  end
end
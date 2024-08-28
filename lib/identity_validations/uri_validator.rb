module IdentityValidations
  class UriValidator < IdentityValidator
    def validate(record)
      if attribute.blank?
        raise ArgumentError, "UriValidator called without an `attribute:` option to validate"
      end
      uri = value(record)
      return if uri.blank?
      record.errors.add(attribute, :invalid) unless uri_valid?(uri)
    end

    def uri_valid?(uri)
      parsed_uri = URI.parse(uri)
      return false if unsupported_uri?(parsed_uri)

      web_uri?(parsed_uri) || native_uri?(parsed_uri) || custom_uri?(parsed_uri)
    rescue URI::BadURIError, URI::InvalidURIError
      false
    end

    def unsupported_uri?(uri)
      !!(/\A(s?ftp|ldaps?|file|mailto)/ =~ uri.scheme)
    end

    private

    def web_uri?(uri)
      !!(/\Ahttps?/ =~ uri.scheme && uri.host.present?)
    end

    def custom_uri?(uri)
      uri.scheme.present? && uri.host.present?
    end

    # Not a strict definition of native uri, but a catch-all
    # to ensure we have the bare minimum
    def native_uri?(uri)
      uri.scheme.present? && uri.path.present?
    end
  end
end

module IdentityValidations
  class AllowedRedirectsValidator < UriValidator
    def validate_each(record, attribute, value)
      Array(value).each do |uri_string|
        record.errors.add(attribute, "#{uri_string} contains invalid wildcards(*)") if uri_string.include?('*')
        record.errors.add(attribute, "#{uri_string} is not a valid URI") if !uri_valid?(uri_string) && !uri_custom_scheme_only?(uri_string)
      end
    end

    private

    def uri_custom_scheme_only?(uri)
      parsed_uri = URI.parse(uri)
      return false if unsupported_uri?(parsed_uri)
      return false if /\Ahttps?/ =~ parsed_uri.scheme

      parsed_uri.scheme.present?
    rescue URI::BadURIError, URI::InvalidURIError
      false
    end
  end
end

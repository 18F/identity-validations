module IdentityValidations
  class AllowedRedirectsValidator < IdentityValidator
    def validate(record)
      self.attribute ||= :redirect_uris
      uris = get_attribute(record)

      return if uris.blank?

      Array(uris).each do |uri_string|
        validating_uri = ValidatingURI.new(uri_string)
        record.errors.add(attribute, "#{uri_string} contains invalid wildcards(*)") if validating_uri.with_wildcards?
        record.errors.add(attribute, "#{uri_string} is not a valid URI") unless validating_uri.valid? || validating_uri.custom_scheme?
      end
    end
  end
end

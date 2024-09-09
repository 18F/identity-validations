module IdentityValidations
  class UriValidator < IdentityValidator
    def validate(record)
      if attribute.blank?
        raise ArgumentError, "UriValidator called without an `attribute:` option to validate"
      end
      uri = get_attribute(record)

      return if uri.blank?

      record.errors.add(attribute, :invalid) unless ValidatingURI.new(uri).valid?
    end
  end
end

module IdentityValidations
  class ValidatingURI
    attr_reader :uri


    def initialize(string)
      @uri = URI.parse(string)
      @did_parse = true
    rescue URI::BadURIError, URI::InvalidURIError
      @did_parse = false
    end

    def parseable?
      @did_parse
    end

    def valid?
      return false if unsupported?

      web? || native? || custom?
    end

    def unsupported?
      return true unless parseable?

      !!(/\A(s?ftp|ldaps?|file|mailto)/ =~ uri.scheme)
    end

    def web?
      return false unless parseable?

      !!(/\Ahttps?/ =~ uri.scheme && uri.host.present?)
    end

    def custom?
      return false unless parseable?

      uri.scheme.present? && uri.host.present?
    end

    # Not a strict definition of native uri, but a catch-all
    # to ensure we have the bare minimum
    def native?
      return false unless parseable?

      uri.scheme.present? && uri.path.present?
    end

    def with_wildcards?
      return false unless parseable?

      uri.to_s.include?('*')
    end

    def custom_scheme?
      return false if unsupported?
      return false if /\Ahttps?/ =~ uri.scheme

      uri.scheme.present?
    end
  end
end

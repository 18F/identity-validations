module IdentityValidations
  class CertsAreX509Validator < IdentityValidator
    def validate(record)
      self.attribute ||= :certs
      Array(get_attribute(record)).each do |cert|
        content = cert_content(cert)

        next if content.blank?

        OpenSSL::X509::Certificate.new(content)
      rescue OpenSSL::X509::CertificateError => e
        record.errors.add(attribute, "#{cert} is invalid - #{e.message}")
      end
    end

    private

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

module IdentityValidations
  class AreX509Validator < ActiveModel::EachValidator
    def validate_each(record, attribute, values)
      Array(values).each do |cert|
        content = cert_content(cert)
        next if content.blank?
        OpenSSL::X509::Certificate.new(content)
      rescue OpenSSL::X509::CertificateError => e
        record.errors.add(:certs, "#{cert} is invalid - #{e.message}")
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

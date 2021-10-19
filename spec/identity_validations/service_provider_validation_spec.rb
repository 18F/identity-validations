# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

RSpec.describe IdentityValidations::ServiceProviderValidation, type: :model do
  let(:valid_urls) { %w[https://example.com https://example.gov/foo app.example.gov://bar] }
  let(:invalid_urls) do
    [
      'not_a_url',
      'http://this has spaces',
      'foo.com',
      '/foo/bar',
      'file:///usr/sbin/evil_script.sh',
      'ftp://user@password:example.com/usr/sbin/evil_script.sh',
      'mailto:sally@example.com?subject=Invalid',
      'ldap://ldap.example.com/dc=example;dc=com?query'
    ]
  end
  let(:nil_cert) { '' }
  let(:test_cert) do
    <<~CERT.strip
      -----BEGIN CERTIFICATE-----
      MIIDjDCCAnQCCQDnXYBYvsXpXzANBgkqhkiG9w0BAQsFADCBhzEeMBwGA1UEAwwV
      aWRwLXNhbmRib3gubG9naW4uZ292MQwwCgYDVQQKDANHU0ExDDAKBgNVBAsMAzE4
      ZjETMBEGA1UEBwwKV2FzaGluZ3RvbjELMAkGA1UECAwCREMxCzAJBgNVBAYTAlVT
      MRowGAYJKoZIhvcNAQkBFgsxOGZAZ3NhLmdvdjAeFw0xNjA2MDYwMTU5MDVaFw0x
      NzA2MDYwMTU5MDVaMIGHMR4wHAYDVQQDDBVpZHAtc2FuZGJveC5sb2dpbi5nb3Yx
      DDAKBgNVBAoMA0dTQTEMMAoGA1UECwwDMThmMRMwEQYDVQQHDApXYXNoaW5ndG9u
      MQswCQYDVQQIDAJEQzELMAkGA1UEBhMCVVMxGjAYBgkqhkiG9w0BCQEWCzE4ZkBn
      c2EuZ292MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5gG/kitp7qar
      rggpjq5psf3/6NE7/F5nSpeyJMcQBZmaxOfKaGW87+ynEcuz9XhbnByYX/zHExPG
      W77g92O5eY8f2Hl1N1vVomaaa359mR3Lljs7PXj0Og+nYnP8TVU31CEaqq0nSx6f
      uKpVzOeUEE7f0IPGzDHNc3V+UFjcJcn1Hwqf4Rw6KT3yIYwEBWWFrtQgCJTv2Wjh
      UBw5vJ38mG2GidiNleI7azHEI6bcYa8B1WitJbiLxSiO56bFcNpwdzNmWOc6KO3H
      oZKVpVv9em6EDry7gVMy2/iBoa92nQr0cb/1F5tx7LJXoFOwyRNAaeeXhiC848Hs
      OejHMxmMXwIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQCWDURUw+ujzp59Cbm+sTCw
      fZldRp49nM3rS/zfNJUo+HNkr3EEtI3EYRfiedTcvl+kN6lli1xqQIYy8K2T/5iC
      GVWHSwLPgACXJaH2/w0a+HLP+caI7XZk/NpngyoZfnKJ8AlzSPyYCvCGPkFawnp1
      Gr110oP+s2JEvONEMrLHVDF8V5d/oU8x8Tf7e/aSDvjkjJJzuDwCzR5ehifPuuS+
      7idgHDOzQXqcWItiXzDGKDZ+lwFdKfnzxYQOTU1kFFb5eolUjU6yL6VTZSypwKuN
      QoA63AC0m/h75svOH1rAqHMQLXif1+QVl1B/E9HtcUy8ql1apkiaq2O91EpNr9JY
      -----END CERTIFICATE-----
    CERT
  end
  let(:invalid_cert) { 'not valid cert content' }
  let(:certs) { [nil_cert] }

  subject do
    IdentityValidations::TestServiceProvider.new(
      issuer: SecureRandom.hex(8),
      friendly_name: SecureRandom.hex(8),
      certs: certs
    )
  end

  it { is_expected.to validate_presence_of(:friendly_name) }
  it { is_expected.to validate_presence_of(:issuer) }
  it do
    is_expected.to \
      allow_value('this:is:an:issuer', 'https://another.issuer').for(:issuer).on(:create)
  end
  it { is_expected.not_to allow_value('issuer with space').for(:issuer).on(:create) }
  it { is_expected.to validate_inclusion_of(:ial).in_array([1, 2]).allow_nil }
  it { is_expected.to allow_value((valid_urls << 'random.scheme:'), [], nil).for(:redirect_uris) }
  it 'correctly validates redirect_uris' do
    (invalid_urls << 'https:').each do |url|
      # check individually since the group would be negated by any one invalid
      # value
      expect(subject).not_to allow_value([url]).for(:redirect_uris)
    end
  end
  it { is_expected.to allow_value(*valid_urls, nil).for(:failure_to_proof_url) }
  it { is_expected.not_to allow_value(*invalid_urls).for(:failure_to_proof_url) }
  it { is_expected.to allow_value(*valid_urls, nil).for(:push_notification_url) }
  it { is_expected.not_to allow_value(*invalid_urls).for(:push_notification_url) }

  describe 'validating certs' do
    context 'with a blank cert' do
      let(:certs) { [''] }
      it { expect(subject).to be_valid }
    end

    context 'with a good cert' do
      let(:certs) { [test_cert] }
      it { expect(subject).to be_valid }
    end

    context 'with a good cert and a bad cert' do
      let(:certs) { [test_cert, 'i-am-a-bad-cert'] }
      it { expect(subject).to_not be_valid }
    end

    context 'inside Rails' do
      let(:certs) { ['cert_file'] }
      let(:file_exists) { false }

      let(:pathname) { Pathname.new('cert_file') }

      before do
        stub_const('Rails', double('Rails'))
        allow(Rails).to receive_message_chain(:root, :join).with('certs', 'sp', 'cert_file.crt').
          and_return(pathname)

        allow(File).to receive(:exist?).with(pathname).and_return(file_exists)
      end

      context 'with a file that exists' do
        let(:file_exists) { true }

        before do
          allow(pathname).to receive(:read).and_return(test_cert)
        end

        it { expect(subject).to be_valid }
      end

      context 'with a file that does not exist' do
        let(:file_exists) { false }
        it 'is valid and does not try to read the file' do
          expect(subject).to be_valid
        end
      end

      context 'wth an invalid file' do
        let(:file_exists) { true }

        before do
          allow(pathname).to receive(:read).and_return(invalid_cert)
        end

        it { expect(subject).not_to be_valid }

        it 'includes the cert filename in the error message' do
          subject.valid?
          cert_errors = subject.errors[:certs].join(' ')
          expect(cert_errors).to include('cert_file')
        end
      end
    end
  end
end

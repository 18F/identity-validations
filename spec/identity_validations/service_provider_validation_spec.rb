# frozen_string_literal: true

RSpec.describe IdentityValidations::ServiceProviderValidation do
  let(:friendly_name) { 'Test SP' }
  let(:issuer) { 'test_issuer' }
  let(:ial) { 1 }
  let(:redirect_uris) do
    [
      'http://example.com/redirect1',
      'https://example.com/redirect2',
      'example-app:/redirect3'
    ]
  end
  let(:failure_to_proof_url) { 'https://example.com/failure_to_proof' }
  let(:push_notification_url) { 'https://example.com/push_notification' }
  let(:nil_cert) { "" }
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
      -----END CERTIFICATE-----`
    CERT
  end
  let(:service_provider) do
    IdentityValidations::TestServiceProvider.new(
      friendly_name: friendly_name,
      issuer: issuer,
      ial: ial,
      redirect_uris: redirect_uris,
      failure_to_proof_url: failure_to_proof_url,
      push_notification_url: push_notification_url,
      saml_client_cert: nil_cert
    )
  end

  before do
    allow_any_instance_of(ActiveRecord::Validations::UniquenessValidator).to receive(:validate_each).and_return(true)
  end

  describe 'valid service providers' do
    it 'validates a valid service provider' do
      service_provider.valid?
      expect(service_provider).to be_valid, "SP not valid due to #{service_provider.errors.messages}"
    end
  end

  describe 'invalid service providers' do
    context 'when the redirect_uris are not uris' do
      let(:redirect_uris) { ['foo'] }
      it 'invalidates a service provider with invalid redirect_uris' do
        service_provider.valid?
        expect(service_provider).not_to be_valid, 'SP should not valid due to invalid redirect_uri'
      end
    end

    context 'when the redirect_uris are file uris' do
      let(:redirect_uris) { ['file:///usr/sbin/evil_script.sh'] }
      it 'invalidates a service provider with invalid redirect_uris' do
        service_provider.valid?
        expect(service_provider).not_to be_valid, 'SP should not valid due to file: redirect_uri'
      end
    end
  end
end

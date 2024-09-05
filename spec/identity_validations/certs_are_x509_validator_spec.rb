# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IdentityValidations::CertsAreX509Validator do
  class CertTestModel
    include ActiveModel::Validations
    attr_accessor :certs
    attr_accessor :draft_certs
  end

  let(:model) { CertTestModel.new }
  let(:known_good_cert) { 
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
  }
  let(:invalid_cert) { 'this is not a valid certificate' }

  describe 'validates_with no other arguments' do
    it 'checks a `certs` attribute and ignores anything else' do
      model.certs = invalid_cert
      model.draft_certs = invalid_cert
      model.validates_with IdentityValidations::CertsAreX509Validator
      expect(model.errors[:certs].count).to be(1)
      expect(model.errors[:certs][0]).to include('is not a valid certificate')
      expect(model.errors[:draft_certs]).to be_empty
    end

    it 'accepts an array' do
      model.certs = [known_good_cert]
      model.validates_with IdentityValidations::CertsAreX509Validator
      expect(model.errors).to be_empty
      expect(model).to be_valid

      model.certs = [known_good_cert, invalid_cert]
      model.validates_with IdentityValidations::CertsAreX509Validator
      expect(model.errors[:certs].count).to be(1)
      expect(model.errors[:certs][0]).to include('is not a valid certificate')
      expect(model.errors[:draft_certs]).to be_empty
    end
  end

  describe 'validates_with when passed an attribute option' do
    it 'checks the passed attribute and ignores anything else' do
      model.certs = invalid_cert
      model.draft_certs = invalid_cert
      model.validates_with IdentityValidations::CertsAreX509Validator, attribute: :draft_certs

      expect(model.errors[:draft_certs].count).to be(1)
      expect(model.errors[:draft_certs][0]).to include('is not a valid certificate')
      expect(model.errors[:certs]).to be_empty
    end

    it 'accepts an array' do
      model.draft_certs = [known_good_cert]
      model.validates_with IdentityValidations::CertsAreX509Validator, attribute: :draft_certs
      expect(model.errors).to be_empty
      expect(model).to be_valid

      model.draft_certs = [known_good_cert, invalid_cert]
      model.validates_with IdentityValidations::CertsAreX509Validator, attribute: :draft_certs
      expect(model.errors[:draft_certs].count).to be(1)
      expect(model.errors[:draft_certs][0]).to include('is not a valid certificate')
      expect(model.errors[:certs]).to be_empty
    end
  end

  it 'allows blank strings' do
    model.certs = [known_good_cert, '']
    model.validates_with IdentityValidations::CertsAreX509Validator

    expect(model.errors).to be_empty
    expect(model).to be_valid

    model.certs = ''
    model.validates_with IdentityValidations::CertsAreX509Validator

    expect(model.errors).to be_empty
    expect(model).to be_valid
  end
end

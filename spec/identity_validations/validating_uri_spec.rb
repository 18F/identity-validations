# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IdentityValidations::ValidatingURI do
  subject { IdentityValidations::ValidatingURI.new(test_url) }
  context 'with an invalid URI' do
    let(:test_url) { 'some words' } 
    
    it { should_not be_parseable }
    it { should_not be_valid}
    it { should be_unsupported }
    it { should_not be_web }
    it { should_not be_with_wildcards }
    it { should_not be_custom }
    it { should_not be_native }
    it { should_not be_custom_scheme }
  end

  describe 'detects a custom scheme' do
    let(:test_url) {'myapp://custom/path' }

    it { should be_parseable }
    it { should be_valid}
    it { should_not be_unsupported }
    it { should_not be_web }
    it { should_not be_with_wildcards }
    it { should be_custom }
    it { should be_native }
    it { should be_custom_scheme }
  end

  describe 'with no host or path' do
    let(:test_url) { 'myapp://' }

    it { should be_parseable }
    it { should_not be_valid}
    it { should_not be_unsupported }
    it { should_not be_web }
    it { should_not be_with_wildcards }
    it { should be_custom_scheme }
    it { should_not be_custom }
    it { should_not be_native }
  end

  describe 'is custom and not native with host and not path' do
    let(:test_url) { 'myapp://host' }

    it { should be_parseable }
    it { should be_valid}
    it { should_not be_unsupported }
    it { should_not be_web }
    it { should_not be_with_wildcards }
    it { should be_custom_scheme }
    it { should be_custom }
    it { should_not be_native }
  end

  describe 'is not custom with path and no host' do
    let(:test_url) { 'myapp:///path' }

    it { should be_parseable }
    it { should be_valid}
    it { should_not be_unsupported }
    it { should_not be_web }
    it { should_not be_with_wildcards }
    it { should be_custom_scheme }
    it { should_not be_custom }
    it { should be_native }
  end

  describe 'detects custom URIs with wildcards' do
    let(:test_url) { 'myapp://*/path' }

    it { should be_parseable }
    it { should be_valid}
    it { should_not be_unsupported }
    it { should_not be_web }
    it { should be_with_wildcards }
    it { should be_custom_scheme }
    it { should be_custom }
    it { should be_native }
  end
end
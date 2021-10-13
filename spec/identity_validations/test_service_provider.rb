# frozen_string_literal: true

require 'identity_validations'
require 'active_model'
require 'active_model/validations'
require 'active_record'
require 'active_record/validations'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  create_table :test_service_providers, force: true do |t|
    t.string 'issuer', null: false
    t.string 'friendly_name'
    t.integer 'ial'
    t.string 'redirect_uris'
    t.text 'failure_to_proof_url'
    t.string 'push_notification_url'
    t.string 'certs'
    t.string 'return_to_sp_url'
  end
end

module IdentityValidations
  class TestServiceProvider < ActiveRecord::Base
    include IdentityValidations::ServiceProviderValidation

    # we need to serialize since SQLite doesn't support arrays
    serialize :redirect_uris, Array
    serialize :certs, Array
  end
end

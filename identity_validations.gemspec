# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'identity_validations/version'

Gem::Specification.new do |spec|
  spec.name          = 'identity_validations'
  spec.version       = IdentityValidations::VERSION
  spec.authors       = ['Douglas Price']
  spec.email         = ['douglas.price@gsa.gov']

  spec.summary       = %q{Provide consistent validation between IDP and Dashboard models.}
  # spec.description = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = 'https://github.com/18F/identity_validations/blob/master/README.md'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'TODO: Set to "http://mygemserver.com"'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/18F/identity_validations'
    spec.metadata['changelog_uri'] = 'https://github.com/18F/identity_validations/blob/master/CHANGELOG.mdlas'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel', '~> 7.1'
  spec.add_development_dependency 'activerecord', '~> 7.1'
  spec.add_development_dependency 'bundler', '>= 2.5'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '=0.75'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'shoulda-matchers'
  spec.add_development_dependency 'sqlite3',"~> 1.4"
end

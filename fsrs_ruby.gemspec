# frozen_string_literal: true

require_relative 'lib/fsrs_ruby/version'

Gem::Specification.new do |spec|
  spec.name = 'fsrs_ruby'
  spec.version = FsrsRuby::VERSION
  spec.authors = ['FSRS Ruby Port']
  spec.email = ['']

  spec.summary = 'Ruby implementation of FSRS (Free Spaced Repetition Scheduler) v6.0'
  spec.description = 'A complete Ruby port of the TypeScript FSRS v6 algorithm for spaced repetition scheduling'
  spec.homepage = 'https://github.com/open-spaced-repetition/fsrs'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.glob('{lib,spec}/**/*') + %w[README.md LICENSE CHANGELOG.md]
  spec.require_paths = ['lib']

  # Development dependencies
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
end

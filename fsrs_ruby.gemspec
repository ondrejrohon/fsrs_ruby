# frozen_string_literal: true

require_relative 'lib/fsrs_ruby/version'

Gem::Specification.new do |spec|
  spec.name = 'fsrs_ruby'
  spec.version = FsrsRuby::VERSION
  spec.authors = ['Ondrej Rohon']
  spec.email = ['ondrej.rohon@gmail.com']

  spec.summary = 'Ruby implementation of FSRS (Free Spaced Repetition Scheduler) v6.0'
  spec.description = <<-DESC
    A complete Ruby port of the TypeScript FSRS v6.0 algorithm for spaced repetition#{' '}
    scheduling. Implements exponential difficulty, linear damping, and 21-parameter#{' '}
    optimization for optimal review timing in flashcard and learning applications.
  DESC

  spec.homepage = 'https://github.com/ondrejrohon/fsrs_ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{spec.homepage}/blob/main/CHANGELOG.md",
    'bug_tracker_uri' => "#{spec.homepage}/issues",
    'documentation_uri' => 'https://rubydoc.info/gems/fsrs_ruby',
    'wiki_uri' => "#{spec.homepage}/wiki",
    'allowed_push_host' => 'https://rubygems.org',
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir.glob('{lib}/**/*') + %w[
    README.md
    LICENSE
    CHANGELOG.md
    VERIFICATION_REPORT.md
    VERIFICATION_SUMMARY.md
    TESTING.md
  ]

  spec.require_paths = ['lib']

  # Development dependencies
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'simplecov', '~> 0.22'

  spec.post_install_message = <<-MSG
    ✨ Thank you for installing fsrs_ruby! ✨

    This is a Ruby port of FSRS v6.0 (Free Spaced Repetition Scheduler).

    📖 Documentation: #{spec.homepage}
    🐛 Report issues: #{spec.homepage}/issues

    Cross-validated with 80%+ test coverage and 8-decimal precision.
  MSG
end

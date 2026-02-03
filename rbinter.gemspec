# frozen_string_literal: true

require_relative "lib/rbinter/version"

Gem::Specification.new do |spec|
  spec.name = "rbinter"
  spec.version = Rbinter::VERSION
  spec.authors = ["Diego Selzlein"]
  spec.email = ["diego@example.com"]

  spec.summary = "Ruby wrapper for Banco Inter API (BolePix)"
  spec.description = "A simple Ruby gem to interact with Banco Inter's API, supporting authentication and Boleto (BolePix) creation."
  spec.homepage = "https://github.com/diego-aslz/rbinter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/diego-aslz/rbinter"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-net_http"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
end

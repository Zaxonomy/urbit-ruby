require_relative 'lib/urbit/version'

Gem::Specification.new do |spec|
  spec.name          = "urbit-api"
  spec.version       = Urbit::VERSION
  spec.authors       = ["Daryl Richter"]
  spec.email         = ["daryl@ngzax.com"]

  spec.summary       = %q{The Ruby interface to the Urbit HTTP API}
  spec.description   = %q{Access your urbit ship the ruby way. It's a Martian gem.}
  spec.homepage      = "https://www.ngzax.com"
  spec.license       = "MIT"

  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.2")

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Zaxonomy/urbit-ruby"
  spec.metadata["changelog_uri"]   = "https://github.com/Zaxonomy/urbit-ruby/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files =  Dir.glob("lib{.rb,/**/*}", File::FNM_DOTMATCH).reject {|f| File.directory?(f) }
  spec.files += %w[urbit-api.gemspec]    # include the gemspec itself because warbler breaks w/o it

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday",        "~> 1.3.0"
  spec.add_dependency "ld-eventsource", "~> 2.0.0"

  spec.add_development_dependency "pry",   "~> 0.13"
  spec.add_development_dependency "rspec", "~> 3.10"
end


lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jsonw/version"

Gem::Specification.new do |spec|
  spec.name          = "jsonw"
  spec.version       = JsonW::VERSION
  spec.authors       = ["Winston Durand"]
  spec.email         = ["me@winstondurand.com"]

  spec.summary       = %q{Test implementation of JSON}
  spec.homepage      = "https://github.com/R167/jsonw"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_development_dependency "json"
  spec.add_development_dependency "oj"
  spec.add_development_dependency "yajl-ruby"
  spec.add_development_dependency "msgpack"
  spec.add_development_dependency "benchmark-ips"

end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'steam_codec/version'

Gem::Specification.new do |spec|
  spec.name          = 'steam_codec'
  spec.version       = SteamCodec::VERSION
  spec.authors       = ['Dāvis']
  spec.email         = ['davispuh@gmail.com']
  spec.description   = 'Load, parse and manage various Steam client, Source Engine file formats. For example VDF and ACF'
  spec.summary       = 'Library for working with different Steam client (and Source engine) file formats.'
  spec.homepage      = 'https://github.com/davispuh/SteamCodec'
  spec.license       = 'UNLICENSE'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'insensitive_hash', '~> 0.3', '>= 0.3.3'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'simplecov'
end

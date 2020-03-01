# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guard/symlink/version'

Gem::Specification.new do |spec|
  spec.name          = 'guard-symlink'
  spec.version       = Guard::Symlink::VERSION
  spec.authors       = ['Thorsten Eckel']
  spec.email         = ['te@znuny.com']

  spec.summary       = 'Guard to symlink watched folders recursively into the current.'
  spec.description   = 'Guard to symlink watched folders recursively into the current.'
  spec.homepage      = 'https://github.com/thorsteneckel/guard-symlink'
  spec.license       = 'MIT'

  spec.files         = Dir['{lib}/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'guard'
  spec.add_dependency 'guard-compat', '~> 1.1'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 12'
  spec.add_development_dependency 'rspec', '~> 3.0'
end

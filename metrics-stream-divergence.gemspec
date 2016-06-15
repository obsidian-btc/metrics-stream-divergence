# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'metrics-stream-divergence'
  s.version = '0.2.3.1'
  s.summary = 'Measurement of divergence in time of the heads of streams'
  s.description = ' '

  s.authors = ['Obsidian Software, Inc']
  s.email = 'opensource@obsidianexchange.com'
  s.homepage = 'https://github.com/obsidian-btc/metrics-stream-divergence'
  s.licenses = ['MIT']

  s.require_paths = ['lib']
  s.files = Dir.glob('{lib}/**/*')
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.2.3'

  s.add_runtime_dependency 'event_store-client-http'
  s.add_runtime_dependency 'serialize'
end

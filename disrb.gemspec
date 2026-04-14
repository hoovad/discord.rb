require_relative 'lib/version'

Gem::Specification.new do |s|
  s.name          = 'disrb'
  s.version       = DiscordApi::VERSION
  s.summary       = 'A Ruby library for interacting with the Discord API.'
  s.description   = 'Discord.rb (not to be confused with discordrb) is a Ruby library that allows you to interact' \
                    ' only with the Discord API. The library is still in development, but really simple tasks can be' \
                    ' done.'
  s.authors       = ['hoovad']
  s.email         = 'hoovad@proton.me'
  s.files         = Dir['lib/**/*.rb', 'README.md', 'CHANGELOG.md', 'LICENSE']
  s.homepage      = 'https://github.com/hoovad/discord.rb'
  s.license       = 'MIT'
  s.required_ruby_version = '>= 2.7.0'
  s.add_dependency 'async', '>= 2.26.0'
  s.add_dependency 'async-http', '>= 0.89.0'
  s.add_dependency 'async-websocket', '>= 0.30.0'
  s.add_dependency 'faraday', '>= 2.13.3'
  s.add_dependency 'faraday-multipart', '>= 1.2.0'
  s.add_dependency 'stringio', '>= 3.2.0'
  s.add_development_dependency 'rubocop', '>= 1.79.0'
  s.add_development_dependency 'ruby-lsp', '>= 0.26.0'
end

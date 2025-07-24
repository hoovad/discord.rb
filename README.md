# discord.rb indev

[Changelog](CHANGELOG.md) | [Licensed under the MIT License](LICENSE)

[![main](https://github.com/hoovad/discord.rb/actions/workflows/main.yml/badge.svg)](https://github.com/hoovad/discord.rb/actions/workflows/main.yml) [![Gem Version](https://badge.fury.io/rb/disrb.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/disrb)

W.I.P. Discord API wrapper written in Ruby for fun.

The test.rb file creates two commands "test" and "test2", that return "Hi" and "Hello World!" respectively, sets the bot's current activity to 'Watching if i work', and sets the presence to online since the program was started provided you provide the required data in `env.rb.template` and rename it to `env.rb`.

!DISCLAIMER! This is project is in development. Expect changes that might break your code at any time.

## Roadmap
- [x] Indev release (v0.1.0)
    - [x] Basic Discord API wrapper
    - [x] Full guild endpoint support
    - [x] Full user endpoint support
    - [x] Full application command endpoint support
    - [x] Logger
    - [x] Basic gateway support
    - [x] RubyGem building and publishing
- [ ] Alpha release (v0.2.0)
  - [ ] Add support for all Discord API endpoints
  - [ ] Add support for all Discord Gateway events and properly handle the connection
  - [ ] Documentation (v0.1.2)
  - [x] Transition to Faraday for HTTP requests (v0.1.1)
  - [x] Functions where all options are optional, check if atleast one is provided (v0.1.1.1)
  - [x] Prefer to use keyword arguments over positional arguments if there are more than 1 optional arguments (v0.1.1.1)
- [ ] Beta release (v0.3.0)
  - [ ] Component support and builder
  - [ ] Sharding support
  - [ ] Rate limit handling
  - [ ] Voice support
  - [ ] Add parameter validation
- [ ] Stable release (v1.0.0)
  - [ ] Bugfixes, consistency and improvements
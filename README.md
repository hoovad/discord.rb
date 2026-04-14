# discord.rb indev

[![Licensed under the MIT license](https://img.shields.io/github/license/hoovad/discord.rb)](LICENSE)
[![Gem Version](https://img.shields.io/gem/v/disrb?logo=ruby&color=green)](https://rubygems.org/gems/disrb)
![project status: active](https://img.shields.io/badge/project_status-active-green)
[![main](https://github.com/hoovad/discord.rb/actions/workflows/main.yml/badge.svg)](https://github.com/hoovad/discord.rb/actions/workflows/main.yml)

[Changelog](CHANGELOG.md) | [Documentation](https://www.rubydoc.info/gems/disrb/) | [Contributing](CONTRIBUTING.md)

> [!IMPORTANT]
> This is project is still in early development. Expect changes that might break your code at any time. If your code suddenly doesn't work but it did on a previous version, check the [Changelog](CHANGELOG.md) for any breaking changes.

W.I.P. Discord API wrapper written in Ruby for fun.

> [!NOTE]
> This is not a full-featured Discord API handler. This gem lets you interact with the Discord API directly without all the baggage. If you want to make a bot extremely easily, this is not what you are looking for.

If you wanted to use this project, but found that something is missing, doesn't work, don't be afraid to open an issue! Read the [Contributing](CONTRIBUTING.md) page.

## Demonstration

The test.rb file creates three commands "test", "test2" and "file", that return "Hi", "Hello World!" and then "Hello World!" plus a file called "file.txt" with content "Hello World in a file!" respectively, sets the bot's current activity to 'Watching if i work', and sets the presence to online since the program was started. If the bot itself has been mentioned, it replies to that message with 'pong'.

> [!NOTE]
> You will need to fill out the required data in `env.rb.template` and rename it to `env.rb` before running `test.rb`.

## How to use this project

The documentation will contain information about the functions implemented in this project. Check it out [here](https://www.rubydoc.info/gems/disrb/).

Most functions in this library return a `Faraday::Response` object. Check the [Faraday documentation](https://www.rubydoc.info/github/lostisland/faraday) for info on how to use that object. 

If you want to get the contents of the response, use the `body` instance method (example: `[Faraday::Response object here].body`). The contents will most likely be JSON. To convert it to a Ruby object, use `JSON.parse([Faraday::Response object here].body)` (with `require 'json'` of course).

> [!TIP]
> When reading the documentation, there most likely will be a link to the relevant Discord Developer Documentation page. Please read that page as well, it will contain information that may help you.

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
    - [ ] Add support for all Discord API endpoints (v0.2.0)
    - [ ] Add support for all Discord Gateway events and properly handle the connection (v0.1.5)
    - [x] Add support for uploading files (v0.1.4)
    - [x] Documentation (v0.1.3)
    - [x] Full message resource support (v0.1.2)
    - [x] Transition to Faraday for HTTP requests (v0.1.1)
- [ ] Beta release (v0.3.0)
    - [ ] Component support and builder
    - [ ] Sharding support
    - [ ] Rate limit handling
    - [ ] Voice support
    - [ ] Add parameter validation
- [ ] Stable release (v1.0.0)
    - [ ] Return classes instead of `Faraday::Response` objects
    - [ ] Bugfixes, consistency and improvements
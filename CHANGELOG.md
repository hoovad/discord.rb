# Version 0.1.2.1 (2025-08-17)

- Fix a bug where connecting to the gateway would always fail

# Version 0.1.2 (2025-07-25)

- Change homepage in gemspec to point to the GitHub repository
- Add full support for the messages resource
- Bump Rubocop CI version to 0.0.4

# Version 0.1.1.3 (2025-07-24)

- Add rubocop to development dependencies (in gemspec)

# Version 0.1.1.2 (2025-07-24)

- Fix some problems with rubocop
- Make the CI ignore rubocop failures so that the CI can still create a release
- Add rubocop to development dependencies (in gemfile)

# Version 0.1.1.1 (2025-07-24)

- Bugfixes
- Make some functions use HandleQueryString where applicable
- Changed "if var" to "unless var.nil?" for consistency
- Functions where all options are optional, check if atleast one is provided
  (keyword arguments over positional arguments if there are more than 1 optional arguments was already done)
- add Gemfile.lock to .gitignore
- since file structure changed, update require path in test.rb
- add link to changelog and license in README.md

# Version 0.1.1 (2025-07-23)

- Fully migrate from Net::HTTP to Faraday for HTTP requests
- Bugfixes
- Add roadmap to README
- Create CHANGELOG.md
- Only build and push the gem when a new tag is created
- Make the CI automatically create a new release with the gem in the attachments

# Version 0.1.0 (2025-07-23)

- Initial discord.rb release as a gem (indev release)
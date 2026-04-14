# v0.1.4.1 (2026-04-14)

- File uploading was just not implemented in `edit_message`
- Fix file uploading function being used incorrectly in `create_message`
- Add new testing function in `test.rb`
- Fix HTTP handlers getting called incorrectly sometimes
- Add file uploading support to `respond_interaction` (you will need to specify `attachments` in the response yourself for now)
- Add uploading files to Discord also via PATCH requests
- Fix Faraday request types being set incorrectly
- Fix payload_json being added to multipart form data incorrectly
- Add info on how to create a new release in `CONTRIBUTING.md`
- Fix some typos and minor mistakes
- Add `Gemfile.lock` and remove it from `.gitignore`

# v0.1.4 (2026-04-05)

- Add support for file uploading
- Fix bug where HTTP handlers would continue executing even after an error
- Add missing User-Agent header in requests to the HTTP API (it can be changed from the default)
- Fix bug where functions may run `body` and `status` functions on a nil object
- Change 200 server limit notice from a warning to an info message in `get_current_user_guilds`
- Slight modifications in `README.md` and `LICENSE`

## Breaking changes

- Any project using `DiscordApi`'s `get`, `post`, `delete`, `put` and `patch` functions will not work, as they have been made private (only functions inside the same class can call them), in order to add functionality for customizing the User-Agent header included in requests to the HTTP API.

# v0.1.3 (2025-11-15)

- Add documentation
- Lots of bugfixes and improvements
- Add replacement/deprecation warnings to parameters in create_guild_application_command and create_global_application_command
- Fix some formatting issues in the README.md with YARD
- Add .yardoc and doc folders to .gitignore
- Add a missing parameter in create_global_application_command
- Remove unnecessary double-empty check in DiscordApi#modify_current_user
- Fix bug where an Array in a String has been treated like an Array in DiscordApi#get_current_user_guilds, and also make sure that the response code is 200 before trying to parse the response
- Add missing implementation for https://discord.com/developers/docs/resources/user#get-current-user-guild-member
- Add information on how to use Faraday::Response objects and notice to read linked Discord documentation in the README.md
- Trim down and make logger.rb code more modular
- The payload_json parameter in DiscordApi#edit_message is only to be included in multipart/form-data requests, not JSON, so we remove it
- Rework the gateway connection reconnect code a bit
- Rework test.rb for the new code and also fix some bugs
- Add file and line information to Logger2 (shows where the logger was called)
- Fix a bug where all Logger2 class functions couldn't find Logger2#base
- Fix a bug, setting communication_disabled_until to false in DiscordApi#modify_guild_member would remove the timeout by sending nil to the Discord API, as specified in the documentation
- Add CHANGELOG.md to files in gemspec
- Add missing parameters in DiscordApi#modify_current_member
- Make nick in DiscordApi#modify_current_user_nick required because its the only modification
- Add support for some other opcodes in DiscordApi#connect_gateway
- Create new class function DiscordApi#bitwise_permission_flags that returns a hash with the key as the permission name (as a symbol) and the value as the bitwise permission flag, and make DiscordApi#calculate_permissions_integer and DiscordApi#reverse_permissions_integer use it to trim down some lines of code
- Move functions related to Application Commands from lib/disrb.rb to a separate file in lib/disrb/application_commands.rb

## Breaking changes

- Rename emoji_id parameters to emoji in all functions related to the Message resource
- Description is a required parameter in create_guild_application_command and create_global_application_command
- Call the block in DiscordApi#connect_gateway on every payload, not just when an interaction is created
  (stop always expecting an interaction when the block is called)
- Fixes where single splat operators didn't play nicely with keyword arguments (in DiscordApi#create_guild_application_commands, DiscordApi#create_global_application_commands)
- In mass-create application command functions, make it so that it returns the response of each request as an array, not just the last request's response
- Move DiscordApi.handle_snowflake to a separate class and slightly change usage for better documentation
- Comment out files/_files parameter in the relevant functions due to uploading files not being implemented yet
  (also skip the relevant functions if only the files parameter is provided)
- Fix implementation of DiscordApi#modify_guild_role_positions, the required parameters are now different
- Apps can no longer create guilds, thus DiscordApi#create_guild has been removed

# Version 0.1.2.2 (2025-08-17)

- Fix a bug where the function wouldn't return even if the status code was the expected one for success
- (and disable Style/MultipleComparison in .rubocop.yml)

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
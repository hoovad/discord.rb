# frozen_string_literal: true

require 'json'
require 'async'
require 'async/http/endpoint'
require 'async/websocket/client'
require 'faraday'
require_relative 'disrb/guild'
require_relative 'disrb/logger'
require_relative 'disrb/user'
require_relative 'disrb/message'

# Contains functions related to Discord snowflakes.
class Snowflake
  # @!attribute [r] snowflake
  #  @return [String] 64-bit binary representation of the snowflake as a string
  # @!attribute [r] discord_epoch_timestamp
  #  @return [String] binary representation of the discord epoch timestamp
  #   (milliseconds since the first second of 2015).
  # @!attribute [r] internal_worker_id
  #  @return [String] Internal worker ID.
  # @!attribute [r] internal_process_id
  #  @return [String] Internal process ID.
  # @!attribute [r] gen_id_on_process
  #  @return [String] Nº of the ID generated on the process. This is incremented every time a new snowflake is generated
  #   on the same process.
  # @!attribute [r] unix_timestamp
  #  @return [Integer] Unix timestamp of the snowflake in milliseconds.
  # @!attribute [r] timestamp
  #  @return [Time] Timestamp of the snowflake in UTC as a Time object.
  attr_accessor(:snowflake, :discord_epoch_timestamp, :internal_worker_id, :internal_process_id, :gen_id_on_process,
                :unix_timestamp, :timestamp)

  # Creates a new Snowflake instance.
  # @param snowflake [Integer] The snowflake to be used.
  # @return [Snowflake] Snowflake instance.
  def initialize(snowflake)
    @snowflake = snowflake.to_s(2).rjust(64, '0')
    @discord_epoch_timestamp = snowflake[0..41]
    @internal_worker_id = snowflake[42..46]
    @internal_process_id = snowflake[47..51]
    @gen_id_on_process = snowflake[52..64]
    @unix_timestamp = snowflake[0..41].to_i(2) + 1_420_070_400_000
    @timestamp = Time.at((snowflake[0..41].to_i(2) + 1_420_070_400_000) / 1000).utc
  end
end

# Class that contains functions that allow interacting with the Discord API.
# @version 0.1.2.2
class DiscordApi
  # @!attribute [r] base_url
  #   @return [String] the base URL that is used to access the Discord API. ex: "https://discord.com/api/v10"
  # @!attribute [r] authorization_header
  #   @return [String] the authorization header that is used to authenticate requests to the Discord API.
  # @!attribute [r] application_id
  #   @return [Integer] the application ID of the bot that has been assigned to the provided authorization token.
  attr_accessor(:base_url, :authorization_header, :application_id, :logger)

  # Creates a new DiscordApi instance. (required to use most functions)
  #
  # @param authorization_token_type [String] The type of authorization token provided by Discord, 'Bot' or 'Bearer'.
  # @param authorization_token [String] The value of the authorization token provided by Discord.
  # @param verbosity_level [String, Integer, nil] The verbosity level of the logger.
  # Set verbosity_level to:
  # - 'all' or 5 to log all of the below plus debug messages
  # - 'info', 4 or nil to log all of the below plus info messages [DEFAULT]
  # - 'warning' or 3 to log all of the below plus warning messages
  # - 'error' or 2 to log fatal errors and error messages
  # - 'fatal_error' or 1 to log only fatal errors
  # - 'none' or 0 for no logging
  # @return [DiscordApi] DiscordApi instance.
  def initialize(authorization_token_type, authorization_token, verbosity_level = nil)
    @api_version = '10'
    @base_url = "https://discord.com/api/v#{@api_version}"
    @authorization_token_type = authorization_token_type
    @authorization_token = authorization_token
    @authorization_header = "#{authorization_token_type} #{authorization_token}"
    if verbosity_level.nil?
      @verbosity_level = 4
    elsif verbosity_level.is_a?(String)
      case verbosity_level.downcase
      when 'all'
        @verbosity_level = 5
      when 'info'
        @verbosity_level = 4
      when 'warning'
        @verbosity_level = 3
      when 'error'
        @verbosity_level = 2
      when 'fatal_error'
        @verbosity_level = 1
      when 'none'
        @verbosity_level = 0
      else
        Logger2.s_error("Unknown verbosity level: #{verbosity_level}. Defaulting to 'info'.")
        @verbosity_level = 4
      end
    elsif verbosity_level.is_a?(Integer)
      if verbosity_level >= 0 && verbosity_level <= 5
        @verbosity_level = verbosity_level
      else
        Logger2.s_error("Unknown verbosity level: #{verbosity_level}. Defaulting to 'info'.")
        @verbosity_level = 4
      end
    else
      Logger2.s_error("Unknown verbosity level: #{verbosity_level}. Defaulting to 'info'.")
      @verbosity_level = 4
    end
    @logger = Logger2.new(@verbosity_level)
    url = "#{@base_url}/applications/@me"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    if response.status == 200
      @application_id = JSON.parse(response.body)['id']
    else
      @logger.fatal_error("Failed to get application ID with response: #{response.body}")
      exit
    end
  end

  # Converts a hash into a valid query string.
  # @example Convert a hash into a query string
  #   DiscordApi.handle_query_strings({'key1' => 'value1', 'key2' => 'value2'}) #=> "?key1=value1&key2=value2"
  # If the hash is empty, it returns an empty string.
  # @param query_string_hash [Hash] The hash to convert into a query string.
  # @return [String] The query string.
  def self.handle_query_strings(query_string_hash)
    query_string_array = []
    query_string_hash.each do |key, value|
      if value.nil?
        next
      elsif query_string_array.empty?
        query_string_array << "?#{key}=#{value}"
      else
        query_string_array << "&#{key}=#{value}"
      end
    end
    query_string_array << '' if query_string_array.empty?
    query_string_array.join
  end

  # Creates an application command specifically for one guild.
  # See https://discord.com/developers/docs/interactions/application-commands#create-guild-application-command
  # @param guild_id [Integer] The ID of the guild where the command will be created.
  # @param name [String] The name of the command.
  # @param name_localizations [Hash, nil] Localized names for the command.
  # @param description [String, nil] The description of the command.
  # @param description_localizations [Hash, nil] Localized descriptions for the command.
  # @param options [Array, nil] Options for the command.
  # @param default_member_permissions [String, nil] Sets the default permission(s) that members need to run the command.
  #   (must be set to a bitwise permission flag as a string)
  # @param default_permission [TrueClass, FalseClass, nil] (replaced by default_member_permissions) Whether the command
  #   is enabled by default when the app is added to a guild.
  # @param type [Integer, nil] The type of the command.
  # @param nsfw [TrueClass, FalseClass, nil] Whether the command is NSFW.
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def create_guild_application_command(guild_id, name, description, name_localizations: nil,
                                       description_localizations: nil, options: nil, default_member_permissions: nil,
                                       default_permission: nil, type: nil, nsfw: nil)
    output = {}
    output[:name] = name
    output[:description] = description
    output[:name_localizations] = name_localizations unless name_localizations.nil?
    output[:description_localizations] = description_localizations unless description_localizations.nil?
    output[:options] = options unless options.nil?
    unless default_permission.nil?
      @logger.warn('The "default_permission" parameter has been replaced by "default_member_permissions" ' \
                     'and will be deprecated in the future.')
      output[:default_permission] = default_permission
    end
    output[:type] = type unless type.nil?
    output[:nsfw] = nsfw unless nsfw.nil?
    output[:default_member_permissions] = default_member_permissions unless default_member_permissions.nil?
    url = "#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.post(url, data, headers)
    return response if response.status == 201 || response.status == 200

    @logger.error("Failed to create guild application command in guild with ID #{guild_id}. Response: #{response.body}")
    response
  end

  # Mass-creates application commands for guild(s).
  # @param application_commands_array [Array] An array of arrays, where the first three elements (of the inner array)
  #   are the values for for the first three parameters (which are required) in the create_guild_application_command
  #   method in order. The fourth element is a Hash that contains the rest of the parameters for the command, the key
  #   must be the name of  the parameter as a symbol (e.g. :description, :options, etc.) and the value must be the value
  #    for that parameter.
  # @return [Array] An array of Faraday::Response objects, one for each command creation request.
  def create_guild_application_commands(application_commands_array)
    response = []
    if application_commands_array.is_a?(Array)
      application_commands_array.each do |parameter_array|
        if parameter_array.is_a?(Array)
          response << create_guild_application_command(*parameter_array[0..2], **parameter_array[3] || {})
        else
          @logger.error("Invalid parameter array: #{parameter_array}. Expected an array of parameters.")
        end
      end
    else
      @logger.error("Invalid application commands array: #{application_commands_array}. Expected an array of arrays.")
    end
    response
  end

  # Creates an application command globally.
  # See https://discord.com/developers/docs/interactions/application-commands#create-global-application-command
  # @param name [String] The name of the command.
  # @param description [String] The description of the command.
  # @param name_localizations [Hash, nil] Localized names for the command.
  # @param description_localizations [Hash, nil] Localized descriptions for the command.
  # @param options [Array, nil] Options for the command.
  # @param default_member_permissions [String, nil] Sets the default permission(s) that members need to run the command.
  #   (must be set to a bitwise permission flag as a string)
  # @param dm_permission [TrueClass, FalseClass, nil] (deprecated, use contexts instead) Whether the command is
  #   available in DMs.
  # @param default_permission [TrueClass, FalseClass, nil] (replaced by default_member_permissions) Whether the command
  #   is enabled by default when the app is added to a guild.
  # @param integration_types [Array, nil] Installation context(s) where the command is available.
  # @param contexts [Array, nil] Interaction context(s) where the command can be used
  # @param type [Integer, nil] The type of the command.
  # @param nsfw [TrueClass, FalseClass, nil] Whether the command is NSFW.
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def create_global_application_command(name, description, name_localizations: nil,
                                        description_localizations: nil, options: nil,
                                        default_member_permissions: nil, dm_permission: nil, default_permission: nil,
                                        integration_types: nil, contexts: nil, type: nil, nsfw: nil)
    output = {}
    output[:name] = name
    output[:description] = description
    output[:name_localizations] = name_localizations unless name_localizations.nil?
    output[:description_localizations] = description_localizations unless description_localizations.nil?
    output[:options] = options unless options.nil?
    output[:type] = type unless type.nil?
    output[:nsfw] = nsfw unless nsfw.nil?
    output[:default_member_permissions] = default_member_permissions unless default_member_permissions.nil?
    unless dm_permission.nil?
      @logger.warn('The "dm_permission" parameter has been deprecated and "contexts" should be used instead!')
      output[:dm_permission] = dm_permission
    end
    unless default_permission.nil?
      @logger.warn('The "default_permission" parameter has been replaced by "default_member_permissions" ' \
                     'and will be deprecated in the future.')
      output[:default_permission] = default_permission
    end
    output[:integration_types] = integration_types unless integration_types.nil?
    output[:contexts] = contexts unless contexts.nil?
    url = "#{@base_url}/applications/#{@application_id}/commands"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.post(url, data, headers)
    return response if response.status == 201 || response.status == 200

    @logger.error("Failed to create global application command. Response: #{response.body}")
    response
  end

  # Mass-creates application commands globally.
  # Each inner array should contain the first two required parameters (name, description) in order,
  # followed by an optional Hash for keyword parameters (e.g., :options, :type, etc.).
  # See https://discord.com/developers/docs/interactions/application-commands#create-global-application-command
  # @param application_commands_array [Array] Array of parameter arrays for command creation.
  # @return [Array] An array of Faraday::Response objects, each one responses Discord API for each command created in
  #   order.
  def create_global_application_commands(application_commands_array)
    response = []
    if application_commands_array.is_a?(Array)
      application_commands_array.each do |parameter_array|
        if parameter_array.is_a?(Array)
          response << create_global_application_command(*parameter_array[0..1], **parameter_array[2] || {})
        else
          @logger.error("Invalid parameter array: #{parameter_array}. Expected an array of parameters.")
        end
      end
    else
      @logger.error("Invalid application commands array: #{application_commands_array}. Expected an array of arrays.")
    end
    response
  end

  # Edits a global application command. Returns 200 OK with the updated command object on success.
  # If none of the optional parameters are specified (modifications), the function logs a warning and returns nil.
  # See https://discord.com/developers/docs/interactions/application-commands#edit-global-application-command
  # @param command_id [String] The ID of the global command to edit.
  # @param name [String, nil] New name of the command.
  # @param name_localizations [Hash, nil] Localized names for the command.
  # @param description [String, nil] New description of the command.
  # @param description_localizations [Hash, nil] Localized descriptions for the command.
  # @param options [Array, nil] New options for the command.
  # @param default_member_permissions [String, nil] New default permissions bitwise string for the command.
  # @param default_permission [TrueClass, FalseClass, nil] (deprecated) Whether the command is enabled by default.
  # @param integration_types [Array, nil] Installation context(s) where the command is available.
  # @param contexts [Array, nil] Interaction context(s) where the command can be used.
  # @param nsfw [TrueClass, FalseClass, nil] Whether the command is NSFW.
  # @return [Faraday::Response, nil] The response from the Discord API, or nil if no modifications were provided.
  def edit_global_application_command(command_id, name: nil, name_localizations: nil, description: nil,
                                      description_localizations: nil, options: nil, default_member_permissions: nil,
                                      default_permission: nil, integration_types: nil, contexts: nil, nsfw: nil)
    if args[1..].all?(&:nil?)
      @logger.warn("No modifications provided for global application command with ID #{command_id}. Skipping.")
      return nil
    end
    output = {}
    output[:name] = name
    output[:name_localizations] = name_localizations unless name_localizations.nil?
    output[:description] = description unless description.nil?
    output[:description_localizations] = description_localizations unless description_localizations.nil?
    output[:options] = options unless options.nil?
    output[:default_permission] = default_permission unless default_permission.nil?
    output[:nsfw] = nsfw unless nsfw.nil?
    output[:default_member_permissions] = default_member_permissions unless default_member_permissions.nil?
    output[:integration_types] = integration_types unless integration_types.nil?
    output[:contexts] = contexts unless contexts.nil?
    url = "#{@base_url}/applications/#{@application_id}/commands/#{command_id}"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.patch(url, data, headers)
    return response if response.status == 200

    @logger.error("Failed to edit global application command with ID #{command_id}. Response: #{response.body}")
    response
  end

  # Edits a guild application command. Returns 200 OK with the updated command object on success.
  # If none of the optional parameters are specified (modifications), the function logs a warning and returns nil.
  # See https://discord.com/developers/docs/interactions/application-commands#edit-guild-application-command
  # @param guild_id [String] The ID of the guild containing the command.
  # @param command_id [String] The ID of the guild command to edit.
  # @param name [String, nil] New name of the command.
  # @param name_localizations [Hash, nil] Localized names for the command.
  # @param description [String, nil] New description of the command.
  # @param description_localizations [Hash, nil] Localized descriptions for the command.
  # @param options [Array, nil] New options for the command.
  # @param default_member_permissions [String, nil] New default permissions bitwise string for the command.
  # @param default_permission [TrueClass, FalseClass, nil] (deprecated) Whether the command is enabled by default.
  # @param nsfw [TrueClass, FalseClass, nil] Whether the command is NSFW.
  # @return [Faraday::Response, nil] The response from the Discord API, or nil if no modifications were provided.
  def edit_guild_application_command(guild_id, command_id, name: nil, name_localizations: nil, description: nil,
                                     description_localizations: nil, options: nil, default_member_permissions: nil,
                                     default_permission: nil, nsfw: nil)
    if args[2..].all?(&:nil?)
      @logger.warn("No modifications provided for guild application command with command ID #{command_id}. Skipping.")
      return nil
    end
    output = {}
    output[:name] = name
    output[:name_localizations] = name_localizations unless name_localizations.nil?
    output[:description] = description unless description.nil?
    output[:description_localizations] = description_localizations unless description_localizations.nil?
    output[:options] = options unless options.nil?
    output[:default_permission] = default_permission unless default_permission.nil?
    output[:nsfw] = nsfw unless nsfw.nil?
    output[:default_member_permissions] = default_member_permissions unless default_member_permissions.nil?
    url = "#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands/#{command_id}"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.patch(url, data, headers)
    return response if response.status == 200

    @logger.error("Failed to edit guild application command with ID #{command_id}. Response: #{response.body}")
    response
  end

  # Deletes a global application command. Returns 204 No Content on success.
  # See https://discord.com/developers/docs/interactions/application-commands#delete-global-application-command
  # @param command_id [String] The ID of the global command to delete.
  # @return [Faraday::Response] The response from the Discord API.
  def delete_global_application_command(command_id)
    url = "#{@base_url}/applications/#{@application_id}/commands/#{command_id}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.delete(url, headers)
    return response if response.status == 204

    @logger.error("Failed to delete global application command with ID #{command_id}. Response: #{response.body}")
    response
  end

  # Deletes a guild application command. Returns 204 No Content on success.
  # See https://discord.com/developers/docs/interactions/application-commands#delete-guild-application-command
  # @param guild_id [String] The ID of the guild containing the command.
  # @param command_id [String] The ID of the guild command to delete.
  # @return [Faraday::Response] The response from the Discord API.
  def delete_guild_application_command(guild_id, command_id)
    url = "#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands/#{command_id}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.delete(url, headers)
    return response if response.status == 204

    @logger.error("Failed to delete guild application command with ID #{command_id} in guild with ID #{guild_id}. " \
                  "Response: #{response.body}")
  end

  # Returns a list of application commands for a guild. Returns 200 OK with an array of command objects.
  # See https://discord.com/developers/docs/interactions/application-commands#get-guild-application-commands
  # @param guild_id [String] The ID of the guild to list commands for.
  # @param with_localizations [TrueClass, FalseClass, nil] Whether to include full localization dictionaries.
  # @return [Faraday::Response] The response from the Discord API.
  def get_guild_application_commands(guild_id, with_localizations: nil)
    query_string_hash = {}
    query_string_hash[:with_localizations] = with_localizations unless with_localizations.nil?
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = "#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands#{query_string}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get guild application commands for guild with ID #{guild_id}. Response: #{response.body}")
    response
  end

  # Returns a list of global application commands for the current application. Returns 200 OK on success.
  # See https://discord.com/developers/docs/interactions/application-commands#get-global-application-commands
  # @param with_localizations [TrueClass, FalseClass, nil] Whether to include full localization dictionaries.
  # @return [Faraday::Response] The response from the Discord API.
  def get_global_application_commands(with_localizations: false)
    query_string_hash = {}
    query_string_hash[:with_localizations] = with_localizations unless with_localizations.nil?
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = "#{@base_url}/applications/#{@application_id}/commands#{query_string}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get global application commands. Response: #{response.body}")
    response
  end

  # Returns a single global application command by ID. Returns 200 OK with the command object.
  # See https://discord.com/developers/docs/interactions/application-commands#get-global-application-command
  # @param command_id [String] The ID of the global command to retrieve.
  # @return [Faraday::Response] The response from the Discord API.
  def get_global_application_command(command_id)
    url = "#{@base_url}/applications/#{@application_id}/commands/#{command_id}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get global application command with ID #{command_id}. Response: #{response.body}")
    response
  end

  # Returns a single guild application command by ID. Returns 200 OK with the command object.
  # See https://discord.com/developers/docs/interactions/application-commands#get-guild-application-command
  # @param guild_id [String] The ID of the guild containing the command.
  # @param command_id [String] The ID of the guild command to retrieve.
  # @return [Faraday::Response] The response from the Discord API.
  def get_guild_application_command(guild_id, command_id)
    url = "#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands/#{command_id}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get guild application command with ID #{command_id}. Response: #{response.body}")
    response
  end

  # Overwrites all global application commands. Returns 200 OK with an array of the new command objects.
  # See https://discord.com/developers/docs/interactions/application-commands#bulk-overwrite-global-application-commands
  # @param commands [Array] Array of command objects (hashes) to set globally.
  # @return [Faraday::Response] The response from the Discord API.
  def bulk_overwrite_global_application_commands(commands)
    url = "#{@base_url}/applications/#{@application_id}/commands"
    data = JSON.generate(commands)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.put(url, data, headers)
    return response if response.status == 200

    @logger.error("Failed to bulk overwrite global application commands. Response: #{response.body}")
    response
  end

  # Overwrites all guild application commands in a guild. Returns 200 OK with an array of the new command objects.
  # See https://discord.com/developers/docs/interactions/application-commands#bulk-overwrite-guild-application-commands
  # @param guild_id [String] The ID of the guild to overwrite commands for.
  # @param commands [Array] Array of command objects (hashes) to set for the guild.
  # @return [Faraday::Response] The response from the Discord API.
  def bulk_overwrite_guild_application_commands(guild_id, commands)
    url = "#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands"
    data = JSON.generate(commands)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.put(url, data, headers)
    return response if response.status == 200

    @logger.error("Failed to bulk overwrite guild application commands in guild with ID #{guild_id}. " \
                    "Response: #{response.body}")
    response
  end

  # Returns all application command permissions for a guild. Returns 200 OK with an array of permissions.
  # See https://discord.com/developers/docs/interactions/application-commands#get-guild-application-command-permissions
  # @param guild_id [String] The ID of the guild to get command permissions for.
  # @return [Faraday::Response] The response from the Discord API.
  def get_guild_application_command_permissions(guild_id)
    url = "#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands/permissions"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get guild application command permissions for guild with ID #{guild_id}. " \
                    "Response: #{response.body}")
    response
  end

  # Returns command permissions for a specific guild command. Returns 200 OK with the permission object.
  # See https://discord.com/developers/docs/interactions/application-commands#get-application-command-permissions
  # @param guild_id [String] The ID of the guild containing the command.
  # @param command_id [String] The ID of the command to get permissions for.
  # @return [Faraday::Response] The response from the Discord API.
  def get_application_command_permissions(guild_id, command_id)
    url = "#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands/#{command_id}/permissions"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get appliaction command permissions for command with ID #{command_id} in guild with ID " \
                    "#{guild_id}. Response: #{response.body}")
    response
  end

  # Edits command permissions for a specific guild command. Returns 200 OK with the updated permissions.
  # See https://discord.com/developers/docs/interactions/application-commands#edit-application-command-permissions
  # @param guild_id [String] The ID of the guild containing the command.
  # @param command_id [String] The ID of the command to edit permissions for.
  # @param permissions [Hash] The permissions payload to set.
  # @return [Faraday::Response] The response from the Discord API.
  def edit_application_command_permissions(guild_id, command_id, permissions)
    url = "#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands/#{command_id}/permissions"
    data = JSON.generate(permissions)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.put(url, data, headers)
    return response if response.status == 200

    @logger.error("Failed to edit application command permissions for command with ID #{command_id} in guild with ID " \
                    "#{guild_id}. Response: #{response.body}")
    response
  end

  # Connects to the Discord Gateway and identifies/resumes the session.
  # This establishes a WebSocket connection, performs Identify/Resume flows, sends/receives heartbeats,
  # and yields gateway events to the provided block.
  # See https://discord.com/developers/docs/topics/gateway and
  # https://discord.com/developers/docs/topics/gateway#identify and
  # https://discord.com/developers/docs/topics/gateway#resume
  # @param activities [Hash, Array, nil] Activity or list of activities to set in presence.
  # @param os [String, nil] OS name reported to the Gateway. Host OS if nil.
  # @param browser [String, nil] Browser/client name reported to the Gateway. "discord.rb" if nil.
  # @param device [String, nil] Device name reported to the Gateway. "discord.rb" if nil
  # @param intents [Integer, nil] Bitwise Gateway intents integer.
  # @param presence_since [Integer, TrueClass, nil] Unix ms timestamp or true for since value in presence.
  # @param presence_status [String, nil] Presence status (e.g., "online", "idle", "dnd").
  # @param presence_afk [TrueClass, FalseClass, nil] Whether the client is AFK.
  # @yield [event] Yields parsed Gateway events to the block if provided.
  # @return [void]
  def connect_gateway(activities: nil, os: nil, browser: nil, device: nil, intents: nil, presence_since: nil,
                      presence_status: nil, presence_afk: nil, &block)
    if @authorization_token_type == 'Bearer'
      acceptable_activities_keys = %w[name type url created_at timestamps application_id details state emoji party
                                      assets secrets instance flags buttons]
    elsif @authorization_token_type == 'Bot'
      acceptable_activities_keys = %w[name state type url]
    end
    if activities.is_a?(Hash)
      activities.each_key do |key|
        next if acceptable_activities_keys.include?(key.to_s)

        @logger.error("Unknown activity key: #{key}. Deleting key from hash.")
        activities.delete(key)
      end
      if activities.empty?
        @logger.error('Empty activity hash. No activities will be sent.')
        activities = nil
      else
        activities = [activities]
      end
    elsif activities.is_a?(Array)
      activities.each do |activity|
        if activity.is_a?(Hash)
          activity.each_key do |key|
            next if acceptable_activities_keys.include?(key.to_s)

            @logger.error("Unknown activity key: #{key}. Deleting key from Hash.")
            activity.delete(key)
          end
          if activity.empty?
            @logger.error('Empty activity hash. Deleting from Array.')
            activities.delete(activity)
          end
        else
          @logger.error("Invalid activity: #{activity}. Expected a Hash. Deleting from Array.")
          activities.delete(activity)
        end
      end
      if activities.empty?
        @logger.error('Empty activities Array. No activities will be sent.')
        activities = nil
      end
    elsif !activities.nil?
      @logger.error("Invalid activities: #{activities}. Expected a Hash or an Array of Hashes.")
      activities = nil
    end
    unless os.is_a?(String) || os.nil?
      @logger.error("Invalid OS: #{os}. Expected a String. Defaulting to #{RbConfig::CONFIG['host_os']}.")
      os = nil
    end
    unless browser.is_a?(String) || browser.nil?
      @logger.error("Invalid browser: #{browser}. Expected a String. Defaulting to 'discord.rb'.")
      browser = nil
    end
    unless device.is_a?(String) || device.nil?
      @logger.error("Invalid device: #{device}. Expected a String. Defaulting to 'discord.rb'.")
      device = nil
    end
    unless (intents.is_a?(Integer) && intents >= 0 && intents <= 131_071) || intents.nil?
      @logger.error("Invalid intents: #{intents}. Expected an Integer between 0 and 131.071. Defaulting to 513" \
                    ' (GUILD_MESSAGES, GUILDS).')
      intents = nil
    end
    unless presence_since.is_a?(Integer) || presence_since == true || presence_since.nil?
      @logger.error("Invalid presence since: #{presence_since}. Expected an Integer or true. Defaulting to nil.")
      presence_since = nil
    end
    unless presence_status.is_a?(String) || presence_status.nil?
      @logger.error("Invalid presence status: #{presence_status}. Expected a String. Defaulting to nil.")
      presence_status = nil
    end
    unless [true, false].include?(presence_afk) || presence_afk.nil?
      @logger.error("Invalid presence afk: #{presence_afk}. Expected a Boolean. Defaulting to nil.")
      presence_afk = nil
    end
    Async do |_task|
      rescue_connection, sequence, resume_gateway_url, session_id = nil
      loop do
        recieved_ready = false
        url = if rescue_connection.nil?
                response = DiscordApi.get("#{@base_url}/gateway")
                if response.status == 200
                  "#{JSON.parse(response.body)['url']}/?v=#{@api_version}&encoding=json"
                else
                  @logger.fatal_error("Failed to get gateway URL. Response: #{response.body}")
                  exit
                end
              else
                "#{rescue_connection[:resume_gateway_url]}/?v=#{@api_version}&encoding=json"
              end
        endpoint = Async::HTTP::Endpoint.parse(url, alpn_protocols: Async::HTTP::Protocol::HTTP11.names)
        Async::WebSocket::Client.connect(endpoint) do |connection|
          if rescue_connection.nil?
            identify = {}
            identify[:op] = 2
            identify[:d] = {}
            identify[:d][:token] = @authorization_header
            identify[:d][:intents] = intents || 513
            identify[:d][:properties] = {}
            identify[:d][:properties][:os] = os || RbConfig::CONFIG['host_os']
            identify[:d][:properties][:browser] = browser || 'discord.rb'
            identify[:d][:properties][:device] = device || 'discord.rb'
            if !activities.nil? || !presence_since.nil? || !presence_status.nil? || !presence_afk.nil?
              identify[:d][:presence] = {}
              identify[:d][:presence][:activities] = activities unless activities.nil?
              if presence_since == true
                identify[:d][:presence][:since] = (Time.now.to_f * 1000).floor
              elsif presence_since.is_a?(Integer)
                identify[:d][:presence][:since] = presence_since
              end
              identify[:d][:presence][:status] = presence_status unless presence_status.nil?
              identify[:d][:presence][:afk] = presence_afk unless presence_afk.nil?
            end
            @logger.debug("Identify payload: #{JSON.generate(identify)}")
            connection.write(JSON.generate(identify))
          else
            @logger.info('Resuming connection...')
            resume = {}
            resume[:op] = 6
            resume[:d] = {}
            resume[:d][:token] = @authorization_header
            resume[:d][:session_id] = rescue_connection[:session_id]
            resume[:d][:seq] = rescue_connection[:sequence]
            @logger.debug("Resume payload: #{JSON.generate(resume)}")
            connection.write(JSON.generate(resume))
            rescue_connection, sequence, resume_gateway_url, session_id = nil
          end
          connection.flush

          loop do
            message = connection.read
            next if message.nil?

            @logger.debug("Raw gateway message: #{message.buffer}")
            message = JSON.parse(message, symbolize_names: true)
            @logger.debug("JSON parsed gateway message: #{message}")

            block.call(message)
            case message
            in { op: 10 }
              @logger.info('Received Hello')
              @heartbeat_interval = message[:d][:heartbeat_interval]
            in { op: 1 }
              @logger.info('Received Heartbeat Request')
              connection.write JSON.generate({ op: 1, d: nil })
              connection.flush
            in { op: 11 }
              @logger.info('Received Heartbeat ACK')
            in { op: 0, t: 'READY' }
              @logger.info('Recieved Ready')
              session_id = message[:d][:session_id]
              resume_gateway_url = message[:d][:resume_gateway_url]
              sequence = message[:s]
              recieved_ready = true
            in { op: 0 }
              @logger.info('An event was dispatched')
              sequence = message[:s]
            in { op: 7 }
              if recieved_ready
                rescue_connection = { session_id: session_id, resume_gateway_url: resume_gateway_url,
                                      sequence: sequence }
                @logger.warn('Received Reconnect. A rescue will be attempted....')
              else
                @logger.warn('Received Reconnect. A rescue cannot be attempted.')
              end
            in { op: 9 }
              if message[:d] && recieved_ready
                rescue_connection = { session_id: session_id, resume_gateway_url: resume_gateway_url,
                                      sequence: sequence }
                @logger.warn('Recieved Invalid Session. A rescue will be attempted...')
              else
                @logger.warn('Recieved Invalid Session. A rescue cannot be attempted.')
              end
            else
              @logger.error("Unimplemented event type with opcode #{message[:op]}")
            end
          end
        end
      rescue Protocol::WebSocket::ClosedError
        @logger.warn('WebSocket connection closed. Attempting reconnect and rescue.')
        if rescue_connection
          @logger.info('Rescue possible. Reconnecting and rescuing...')
        else
          @logger.info('Rescue not possible. Reconnecting...')
        end
        next
      end
    end
  end

  # Creates a response to an interaction. Returns 204 No Content by default, or 200 OK with the created message
  # if `with_response` is true and the response type expects it.
  # See https://discord.com/developers/docs/interactions/receiving-and-responding#create-interaction-response
  # @param interaction [Hash] The interaction payload received from the Gateway.
  # @param response [Hash] The interaction response payload.
  # @param with_response [TrueClass, FalseClass] Whether to request the created message in the response.
  # @return [Faraday::Response] The response from the Discord API.
  def respond_interaction(interaction, response, with_response: false)
    query_string_hash = {}
    query_string_hash[:with_response] = with_response
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = "#{@base_url}/interactions/#{interaction[:d][:id]}/#{interaction[:d][:token]}/callback#{query_string}"
    data = JSON.generate(response)
    headers = { 'content-type': 'application/json' }
    response = DiscordApi.post(url, data, headers)
    return response if (response.status == 204 && !with_response) || (response.status == 200 && with_response)

    @logger.error("Failed to respond to interaction. Response: #{response.body}")
    response
  end

  # Returns a hash of permission names and their corresponding bitwise values.
  # See https://discord.com/developers/docs/topics/permissions#permissions-bitwise-permission-flags
  def self.bitwise_permission_flags
    {
      create_instant_invite: 1 << 0,
      kick_members: 1 << 1,
      ban_members: 1 << 2,
      administrator: 1 << 3,
      manage_channels: 1 << 4,
      manage_guild: 1 << 5,
      add_reactions: 1 << 6,
      view_audit_log: 1 << 7,
      priority_speaker: 1 << 8,
      stream: 1 << 9,
      view_channel: 1 << 10,
      send_messages: 1 << 11,
      send_tts_messages: 1 << 12,
      manage_messages: 1 << 13,
      embed_links: 1 << 14,
      attach_files: 1 << 15,
      read_message_history: 1 << 16,
      mention_everyone: 1 << 17,
      use_external_emojis: 1 << 18,
      view_guild_insights: 1 << 19,
      connect: 1 << 20,
      speak: 1 << 21,
      mute_members: 1 << 22,
      deafen_members: 1 << 23,
      move_members: 1 << 24,
      use_vad: 1 << 25,
      change_nickname: 1 << 26,
      manage_nicknames: 1 << 27,
      manage_roles: 1 << 28,
      manage_webhooks: 1 << 29,
      manage_guild_expressions: 1 << 30,
      use_application_commands: 1 << 31,
      request_to_speak: 1 << 32,
      manage_events: 1 << 33,
      manage_threads: 1 << 34,
      create_public_threads: 1 << 35,
      create_private_threads: 1 << 36,
      use_external_stickers: 1 << 37,
      send_messages_in_threads: 1 << 38,
      use_embedded_activities: 1 << 39,
      moderate_members: 1 << 40,
      view_creator_monetization_analytics: 1 << 41,
      use_soundboard: 1 << 42,
      create_guild_expressions: 1 << 43,
      create_events: 1 << 44,
      use_external_sounds: 1 << 45,
      send_voice_messages: 1 << 46,
      send_polls: 1 << 49,
      use_external_apps: 1 << 50,
      pin_messages: 1 << 51
    }
  end

  # Calculates a permissions integer from an array of permission names.
  # See https://discord.com/developers/docs/topics/permissions#permissions-bitwise-permission-flags
  # @param permissions [Array] Array of permission names as strings or symbols, case insensitive, use underscores
  #   between spaces.
  # @return [Integer] Bitwise OR of all permission flags.
  def self.calculate_permissions_integer(permissions)
    permissions = permissions.map do |permission|
      DiscordApi.bitwise_permission_flags[permission.downcase.to_sym]
    end
    permissions.reduce(0) { |acc, n| acc | n }
  end

  # Reverses a permissions integer back into an array of permission names.
  # See https://discord.com/developers/docs/topics/permissions#permissions-bitwise-permission-flags
  # @param permissions_integer [Integer] Bitwise permissions integer.
  # @return [Array] Array of permission names present (as symbols) in the integer.
  def self.reverse_permissions_integer(permissions_integer)
    permissions = []
    DiscordApi.bitwise_permission_flags.each do |permission, value|
      permissions << permission if (permissions_integer & value) != 0
    end
    permissions
  end

  # Calculates a gateway intents integer from an array of intent names.
  # See https://discord.com/developers/docs/topics/gateway#gateway-intents
  # @param intents [Array] Array of gateway intent names as strings or symbols, case insensitive, use underscores
  #   between spaces.
  # @return [Integer] Bitwise OR of all intents flags.
  def self.calculate_gateway_intents(intents)
    bitwise_intent_flags = {
      guilds: 1 << 0,
      guild_members: 1 << 1,
      guild_bans: 1 << 2,
      guild_emojis_and_stickers: 1 << 3,
      guild_integrations: 1 << 4,
      guild_webhooks: 1 << 5,
      guild_invites: 1 << 6,
      guild_voice_states: 1 << 7,
      guild_presences: 1 << 8,
      guild_messages: 1 << 9,
      guild_message_reactions: 1 << 10,
      guild_message_typing: 1 << 11,
      direct_messages: 1 << 12,
      direct_message_reactions: 1 << 13,
      direct_message_typing: 1 << 14,
      message_content: 1 << 15,
      guild_scheduled_events: 1 << 16
    }
    intents = intents.map do |intent|
      bitwise_intent_flags[intent.downcase.to_sym]
    end
    intents.reduce(0) { |acc, n| acc | n }
  end

  # Performs an HTTP GET request using Faraday.
  # @param url [String] Full URL including scheme and host; path may be included.
  # @param headers [Hash, nil] Optional request headers.
  # @return [Faraday::Response] The Faraday response object.
  def self.get(url, headers = nil)
    split_url = url.split(%r{(http[^/]+)(/.*)}).reject(&:empty?)
    @logger.error("Empty/invalid URL provided: #{url}. Cannot perform GET request.") if split_url.empty?
    host = split_url[0]
    path = split_url[1] if split_url[1]
    conn = Faraday.new(url: host, headers: headers)
    if path
      conn.get(path)
    else
      conn.get
    end
  end

  # Performs an HTTP DELETE request using Faraday.
  # @param url [String] Full URL including scheme and host; path may be included.
  # @param headers [Hash, nil] Optional request headers.
  # @return [Faraday::Response] The Faraday response object.
  def self.delete(url, headers = nil)
    split_url = url.split(%r{(http[^/]+)(/.*)}).reject(&:empty?)
    @logger.error("Empty/invalid URL provided: #{url}. Cannot perform DELETE request.") if split_url.empty?
    host = split_url[0]
    path = split_url[1] if split_url[1]
    conn = Faraday.new(url: host, headers: headers)
    if path
      conn.delete(path)
    else
      conn.delete
    end
  end

  # Performs an HTTP POST request using Faraday.
  # @param url [String] Full URL including scheme and host; path may be included.
  # @param data [String] Serialized request body (e.g., JSON string).
  # @param headers [Hash, nil] Optional request headers.
  # @return [Faraday::Response] The Faraday response object.
  def self.post(url, data, headers = nil)
    split_url = url.split(%r{(http[^/]+)(/.*)}).reject(&:empty?)
    @logger.error("Empty/invalid URL provided: #{url}. Cannot perform POST request.") if split_url.empty?
    host = split_url[0]
    path = split_url[1] if split_url[1]
    conn = Faraday.new(url: host, headers: headers)
    if path
      conn.post(path, data)
    else
      conn.post('', data)
    end
  end

  # Performs an HTTP PATCH request using Faraday.
  # @param url [String] Full URL including scheme and host; path may be included.
  # @param data [String] Serialized request body (e.g., JSON string).
  # @param headers [Hash, nil] Optional request headers.
  # @return [Faraday::Response] The Faraday response object.
  def self.patch(url, data, headers = nil)
    split_url = url.split(%r{(http[^/]+)(/.*)}).reject(&:empty?)
    @logger.error("Empty/invalid URL provided: #{url}. Cannot perform PATCH request.") if split_url.empty?
    host = split_url[0]
    path = split_url[1] if split_url[1]
    conn = Faraday.new(url: host, headers: headers)
    if path
      conn.patch(path, data)
    else
      conn.patch('', data)
    end
  end

  # Performs an HTTP PUT request using Faraday.
  # @param url [String] Full URL including scheme and host; path may be included.
  # @param data [String] Serialized request body (e.g., JSON string).
  # @param headers [Hash, nil] Optional request headers.
  # @return [Faraday::Response] The Faraday response object.
  def self.put(url, data, headers = nil)
    split_url = url.split(%r{(http[^/]+)(/.*)}).reject(&:empty?)
    @logger.error("Empty/invalid URL provided: #{url}. Cannot perform PUT request.") if split_url.empty?
    host = split_url[0]
    path = split_url[1] if split_url[1]
    conn = Faraday.new(url: host, headers: headers)
    if path
      conn.put(path, data)
    else
      conn.put('', data)
    end
  end
end

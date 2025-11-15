# frozen_string_literal: true

# Class that contains functions that allow interacting with the Discord API.
class DiscordApi
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
  # @param application_commands_array [Array] An array of arrays, where the first two elements (of the inner array)
  #   are the values for for the first two parameters (which are required) in the create_global_application_command
  #   method in order. The third element is a Hash that contains the rest of the parameters for the command, the key
  #   must be the name of  the parameter as a symbol (e.g. :description, :options, etc.) and the value must be the value
  #    for that parameter.
  # @return [Array] An array of Faraday::Response objects, one for each command creation request.
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
end

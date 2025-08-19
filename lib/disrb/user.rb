# frozen_string_literal: true

# rubocop:disable Naming/AccessorMethodName

# Class that contains functions that allow interacting with the Discord API.
class DiscordApi
  # Returns the user object of the current user. See https://discord.com/developers/docs/resources/user#get-current-user
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def get_current_user
    url = "#{@base_url}/users/@me"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get current user. Response: #{response.body}")
    response
  end

  # Returns the user object of the specified user. See https://discord.com/developers/docs/resources/user#get-user
  # @param user_id [String] The ID of the user.
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def get_user(user_id)
    url = "#{@base_url}/users/#{user_id}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get user with ID #{user_id}. Response: #{response.body}")
    response
  end

  # Modifies the current user. See https://discord.com/developers/docs/resources/user#modify-current-user
  #
  # If none of the parameters are provided, the function will not proceed and return nil.
  # @param username [String, nil] The new username for the current user. May cause discriminator to be randomized.
  # @param avatar [String, nil] The new avatar for the current user. See https://discord.com/developers/docs/reference#image-data
  # @param banner [String, nil] The new banner for the current user. See https://discord.com/developers/docs/reference#image-data
  # @return [Faraday::Response, nil] The response from the Discord API as a Faraday::Response object or nil if no
  #   modifications were provided.
  def modify_current_user(username: nil, avatar: nil, banner: nil)
    output = {}
    output[:username] = username unless username.nil?
    output[:avatar] = avatar unless avatar.nil?
    output[:banner] = banner unless banner.nil?
    if output.empty?
      @logger.warn('No current user modifications provided. Skipping function.')
      return
    end
    url = "#{@base_url}/users/@me"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.patch(url, data, headers)
    return response if response.status == 200

    @logger.error("Failed to modify current user. Response: #{response.body}")
    response
  end

  # Returns an array of (partial) guild objects that the current user is a member of.
  # See https://discord.com/developers/docs/resources/user#get-current-user-guilds
  # @param before [String, nil] Get guilds before this guild ID.
  # @param after [String, nil] Get guilds after this guild ID.
  # @param limit [Integer, nil] Maximum number of guilds to return. 1-200 allowed, 200 default.
  # @param with_counts [TrueClass, FalseClass, nil] Whether to include approximate member and presence counts in
  #   response.
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def get_current_user_guilds(before: nil, after: nil, limit: nil, with_counts: nil)
    query_string_hash = {}
    query_string_hash[:before] = before unless before.nil?
    query_string_hash[:after] = after unless after.nil?
    query_string_hash[:limit] = limit unless limit.nil?
    query_string_hash[:with_counts] = with_counts unless with_counts.nil?
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = "#{@base_url}/users/@me/guilds#{query_string}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    if @authorization_token_type == 'Bot' && response.body.count == 200
      @logger.warn('A bot can be in more than 200 guilds, however 200 guilds were returned.' \
                    'Discord API doesn\'t allow you to fetch more than 200 guilds. Some guilds might not be listed.')
      return response
    end
    return response if response.status == 200

    @logger.error("Failed to get current user's guilds. Response: #{response.body}")
    response
  end

  # Returns a guild member object for the current user in the specified guild.
  # See https://discord.com/developers/docs/resources/user#get-current-user-guild-member
  # @param guild_id [String] The ID of the guild to get the current user's guild member for.
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def get_current_user_guild_member(guild_id)
    url = "#{@base_url}/users/@me/guilds/#{guild_id}/member"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response unless response.status != 200

    @logger.error("Failed to get current user's guild member for guild ID with ID #{guild_id}. Response: " \
                    "#{response.body}")
    response
  end

  # Leaves a guild for the current user. If it succeeds, the response will have a status code of 204 (Empty Response),
  # and thus the response body will be empty.
  # See https://discord.com/developers/docs/resources/user#leave-guild
  # @param guild_id [String] The ID of the guild to leave.
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def leave_guild(guild_id)
    url = "#{@base_url}/users/@me/guilds/#{guild_id}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.delete(url, headers)
    return response if response.status == 204

    @logger.error("Failed to leave guild with ID #{guild_id}. Response: #{response.body}")
    response
  end

  # Creates a DM channel with the specified user. Returns a DM channel object
  # (if one already exists, it will return that channel).
  # See https://discord.com/developers/docs/resources/user#create-dm
  # @param recipient_id [String] The ID of the user to create a DM channel with.
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def create_dm(recipient_id)
    url = "#{@base_url}/users/@me/channels"
    data = JSON.generate({ recipient_id: recipient_id })
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.post(url, data, headers)
    return response if response.status == 200

    @logger.error("Failed to create DM with recipient ID #{recipient_id}. Response: #{response.body}")
    response
  end

  # Creates a group DM channel with the specified users. Returns a group DM channel object.
  # See https://discord.com/developers/docs/resources/user#create-group-dm
  # @param access_tokens [Array] An array of access tokens (as strings) of users that have granted your app the gdm.join
  #   OAuth2 scope
  # @param nicks [Hash] "a dictionary of user ids to their respective nicknames" (whatever that means)
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def create_group_dm(access_tokens, nicks)
    output = {}
    output[:access_tokens] = access_tokens
    output[:nicks] = nicks
    url = "#{@base_url}/users/@me/channels"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.post(url, data, headers)
    return response if response.status == 200

    @logger.error("Failed to create group DM. Response: #{response.body}")
    response
  end

  # Returns an array of connection objects for the current user. Requires the connections OAuth2 scope.
  # See https://discord.com/developers/docs/resources/user#get-current-user-connections
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def get_current_user_connections
    url = "#{@base_url}/users/@me/connections"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get current user's connections. Response: #{response.body}")
    response
  end

  # Returns the application role connection object for the user. Requires the role_connections.write OAuth2 scope for
  # the application specified.
  # See https://discord.com/developers/docs/resources/user#get-current-user-application-role-connection
  # @param application_id [String] The ID of the application to get the role connection for.
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def get_current_user_application_role_connection(application_id)
    url = "#{@base_url}/users/@me/applications/#{application_id}/role-connection"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get current user's application role connection for application ID #{application_id}. " \
                  "Response: #{response.body}")
    response
  end

  # Updates and returns the application role connection object for the user. Requires the role_connections.write OAuth2
  # scope for the application specified.
  # See https://discord.com/developers/docs/resources/user#update-current-user-application-role-connection
  #
  # If none of the optional parameters are provided (modifications), the function will not proceed and return nil.
  # @param application_id [String] The ID of the application to update the role connection for.
  # @param platform_name [String, nil] The vanity name of the platform a bot has connected (max 50 chars)
  # @param platform_username [String, nil] The username on the platform a bot has connected (max 100 chars)
  # @param metadata [Hash, nil] Hash mapping application role connection metadata keys to their string-ified values
  #   (max 100 chars) for the user on the platform a bot has connected.
  # @return [Faraday::Response, nil] The response from the Discord API as a Faraday::Response object or nil if no
  #   modifications were provided.
  def update_current_user_application_role_connection(application_id, platform_name: nil, platform_username: nil,
                                                      metadata: nil)
    output = {}
    output[:platform_name] = platform_name if platform_name
    output[:platform_username] = platform_username if platform_username
    output[:metadata] = metadata if metadata
    if output.empty?
      @logger.warn('No current user application role connection modifications provided. Skipping function.')
      return
    end
    url = "#{@base_url}/users/@me/applications/#{application_id}/role-connection"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.put(url, data, headers)
    return response if response.status == 200

    @logger.error("Failed to update current user's application role connection for application ID #{application_id}. " \
                    "Response: #{response.body}")
    response
  end
end
# rubocop:enable Naming/AccessorMethodName

# frozen_string_literal: true

# rubocop:disable Naming/AccessorMethodName

# DiscordApi
# The class that contains everything that interacts with the Discord API.
class DiscordApi
  def get_current_user
    url = URI("#{@base_url}/users/@me")
    headers = { 'Authorization': @authorization_header }
    response = Net::HTTP.get(url, headers)
    return response unless response.code != '200'

    @logger.error("Failed to get current user. Response: #{response.body}")
    response
  end

  # TODO: I should consistenly check that the variables are set correctly
  def get_user(user_id)
    url = URI("#{@base_url}/users/#{user_id}")
    headers = { 'Authorization': @authorization_header }
    response = Net::HTTP.get(url, headers)
    return response unless response.code != '200'

    @logger.error("Failed to get user with ID #{user_id}. Response: #{response.body}")
    response
  end

  def modify_current_user(username: nil, avatar: nil, banner: nil)
    output = {}
    output[:username] = username if username
    output[:avatar] = avatar if avatar
    output[:banner] = banner if banner
    # TODO: where all parameters are optional, i should consistently check if the parameters are empty, then skip if yes
    if output.empty?
      @logger.warn('No current user modifications provided. Skipping function.')
      return
    end
    url = URI("#{@base_url}/users/@me")
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = Net::HTTP.patch(url, data, headers)
    return response unless response.code != '200'

    @logger.error("Failed to modify current user. Response: #{response.body}")
    response
  end

  def get_current_user_guilds(before: nil, after: nil, limit: nil, with_counts: nil)
    query_string_hash = {}
    query_string_hash[:before] = before
    query_string_hash[:after] = after
    query_string_hash[:limit] = limit
    query_string_hash[:with_counts] = with_counts
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = URI("#{@base_url}/users/@me/guilds#{query_string}")
    headers = { 'Authorization': @authorization_header }
    response = Net::HTTP.get(url, headers)
    if @authorization_token_type == 'Bot' && response.body.count == 200
      @logger.warn('A bot can be in more than 200 guilds, however 200 guilds were returned.' \
                    'Discord API doesn\'t allow you to fetch more than 200 guilds. Some guilds might not be listed.')
      return response
    end
    return response unless response.code != '200'

    @logger.error("Failed to get current user's guilds. Response: #{response.body}")
    response
  end

  def leave_guild(guild_id)
    url = URI("#{@base_url}/users/@me/guilds/#{guild_id}")
    headers = { 'Authorization': @authorization_header }
    response = Net::HTTP.delete(url, headers)
    return response unless response.code != '204'

    @logger.error("Failed to leave guild with ID #{guild_id}. Response: #{response.body}")
    response
  end

  def create_dm(recipient_id)
    url = URI("#{@base_url}/users/@me/channels")
    data = JSON.generate({ recipient_id: recipient_id })
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = Net::HTTP.post(url, data, headers)
    return response unless response.code != '200'

    @logger.error("Failed to create DM with recipient ID #{recipient_id}. Response: #{response.body}")
    response
  end

  def create_group_dm(access_tokens, nicks)
    output = {}
    output[:access_tokens] = access_tokens
    output[:nicks] = nicks
    url = URI("#{@base_url}/users/@me/channels")
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = Net::HTTP.post(url, data, headers)
    return response unless response.code != '200'

    @logger.error("Failed to create group DM. Response: #{response.body}")
    response
  end

  def get_current_user_connections
    url = URI("#{@base_url}/users/@me/connections")
    headers = { 'Authorization': @authorization_header }
    response = Net::HTTP.get(url, headers)
    return response unless response.code != '200'

    @logger.error("Failed to get current user's connections. Response: #{response.body}")
    response
  end

  def get_current_user_application_role_connection(application_id)
    url = URI("#{@base_url}/users/@me/applications/#{application_id}/role-connection")
    headers = { 'Authorization': @authorization_header }
    response = Net::HTTP.get(url, headers)
    return response unless response.code != '200'

    @logger.error("Failed to get current user's application role connection for application ID #{application_id}. " \
                  "Response: #{response.body}")
    response
  end

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
    url = URI("#{@base_url}/users/@me/applications/#{application_id}/role-connection")
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = Net::HTTP.put(url, data, headers)
    return response unless response.code != '200'

    @logger.error("Failed to update current user's application role connection for application ID #{application_id}. " \
                    "Response: #{response.body}")
    response
  end
end
# rubocop:enable Naming/AccessorMethodName

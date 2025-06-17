# frozen_string_literal: true

# DiscordApi
# The class that contains everything that interacts with the Discord API.
class DiscordApi
  def create_guild(name, region = nil, icon = nil, verification_level = nil, default_message_notifications = nil,
                   explicit_content_filter = nil, roles = nil, channels = nil, afk_channel_id = nil, afk_timeout = nil,
                   system_channel_id = nil, system_channel_flags = nil)
    output = {}
    output[:name] = name
    unless region.nil?
      Logger.warn('The "region" parameter has been deprecated and should not be used!')
      output[:region] = region
    end
    output[:icon] = icon unless icon.nil?
    output[:verification_level] = verification_level unless verification_level.nil?
    output[:default_message_notifications] = default_message_notifications unless default_message_notifications.nil?
    output[:explicit_content_filter] = explicit_content_filter unless explicit_content_filter.nil?
    output[:roles] = roles unless roles.nil?
    output[:channels] = channels unless channels.nil?
    output[:afk_channel_id] = afk_channel_id unless afk_channel_id.nil?
    output[:afk_timeout] = afk_timeout unless afk_timeout.nil?
    output[:system_channel_id] = system_channel_id unless system_channel_id.nil?
    output[:system_channel_flags] = system_channel_flags unless system_channel_flags.nil?
    url = URI("#{@base_url}/guilds")
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    Net::HTTP.post(url, data, headers)
  end

  def get_guild(guild_id, with_counts = nil)
    url = if !with_counts.nil?
            URI("#{@base_url}/guilds/#{guild_id}?with_counts=#{with_counts}")
          else
            URI("#{@base_url}/guilds/#{guild_id}")
          end
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.get(url, headers)
  end

  def get_guild_preview(guild_id)
    url = URI("#{@base_url}/guilds/#{guild_id}/preview")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.get(url, headers)
  end

  def modify_guild(guild_id, name = nil, region = nil, verification_level = nil, default_message_notifications = nil,
                   explicit_content_filter = nil, afk_channel_id = nil, afk_timeout = nil, icon = nil, owner_id = nil,
                   splash = nil, discovery_splash = nil, banner = nil, system_channel_id = nil,
                   system_channel_flags = nil, rules_channel_id = nil, public_updates_channel_id = nil,
                   preferred_locale = nil, features = nil, description = nil, premium_progress_bar_enabled = nil,
                   safety_alerts_channel_id = nil)
    output = {}
    output[:name] = name unless name.nil?
    unless region.nil?
      Logger.warn('The "region" parameter has been deprecated and should not be used!')
      output[:region] = region
    end
    output[:verification_level] = verification_level unless verification_level.nil?
    output[:default_message_notifications] = default_message_notifications unless default_message_notifications.nil?
    output[:explicit_content_filter] = explicit_content_filter unless explicit_content_filter.nil?
    output[:afk_channel_id] = afk_channel_id unless afk_channel_id.nil?
    output[:afk_timeout] = afk_timeout unless afk_timeout.nil?
    output[:icon] = icon unless icon.nil?
    output[:owner_id] = owner_id unless owner_id.nil?
    output[:splash] = splash unless splash.nil?
    output[:discovery_splash] = discovery_splash unless discovery_splash.nil?
    output[:banner] = banner unless banner.nil?
    output[:system_channel_id] = system_channel_id unless system_channel_id.nil?
    output[:system_channel_flags] = system_channel_flags unless system_channel_flags.nil?
    output[:rules_channel_id] = rules_channel_id unless rules_channel_id.nil?
    output[:public_updates_channel_id] = public_updates_channel_id unless public_updates_channel_id.nil?
    output[:preferred_locale] = preferred_locale unless preferred_locale.nil?
    output[:features] = features unless features.nil?
    output[:description] = description unless description.nil?
    output[:premium_progress_bar_enabled] = !premium_progress_bar_enabled.nil?
    output[:safety_alerts_channel_id] = safety_alerts_channel_id unless safety_alerts_channel_id.nil?
    url = URI("#{@base_url}/guilds/#{guild_id}")
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    Net::HTTP.patch(url, headers, data)
  end

  def delete_guild(guild_id)
    url = URI("#{@base_url}/guilds/#{guild_id}")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.delete(url, headers)
  end

  def get_guild_channels(guild_id)
    url = URI("#{@base_url}/guilds/#{guild_id}/channels")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.get(url, headers)
  end

  def create_guild_channel(guild_id, name, type = nil, topic = nil, bitrate = nil, user_limit = nil,
                           rate_limit_per_user = nil, position = nil, permission_overwrites = nil, parent_id = nil,
                           nsfw = nil, rtc_region = nil, video_quality_mode = nil, default_auto_archive_duration = nil,
                           default_reaction_emoji = nil, available_tags = nil, default_sort_order = nil,
                           default_forum_layout = nil, default_thread_rate_limit_per_user = nil)
    output = {}
    output[:name] = name
    output[:type] = type unless type.nil?
    output[:topic] = topic unless topic.nil?
    output[:bitrate] = bitrate unless user_limit.nil?
    output[:user_limit] = user_limit unless user_limit.nil?
    output[:rate_limit_per_user] = rate_limit_per_user unless rate_limit_per_user.nil?
    output[:position] = position unless position.nil?
    output[:permission_overwrites] = permission_overwrites unless permission_overwrites.nil?
    output[:parent_id] = parent_id unless parent_id.nil?
    output[:nsfw] = nsfw unless nsfw.nil?
    output[:rtc_region] = rtc_region unless rtc_region.nil?
    output[:video_quality_mode] = video_quality_mode unless video_quality_mode.nil?
    output[:default_auto_archive_duration] = default_auto_archive_duration unless default_auto_archive_duration.nil?
    output[:default_reaction_emoji] = default_reaction_emoji unless default_reaction_emoji.nil?
    output[:available_tags] = available_tags unless available_tags.nil?
    output[:default_sort_order] = default_sort_order unless default_sort_order.nil?
    output[:default_forum_layout] = default_forum_layout unless default_forum_layout.nil?
    unless default_thread_rate_limit_per_user.nil?
      output[:default_thread_rate_limit_per_user] =
        default_thread_rate_limit_per_user
    end
    url = URI("#{@base_url}/guilds/#{guild_id}/channels")
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    Net::HTTP.post(url, data, headers)
  end

  def modify_guild_channel_positions(guild_id, channel_id, position = nil, lock_permissions = nil, parent_id = nil)
    output = {}
    output[:id] = channel_id
    output[:position] = position unless position.nil?
    output[:lock_permissions] = lock_permissions unless lock_permissions.nil?
    output[:parent_id] = parent_id unless parent_id.nil?
    url = URI("#{@base_url}/guilds/#{guild_id}/channels")
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    Net::HTTP.patch(url, headers, data)
  end

  def list_active_guild_threads(guild_id)
    url = URI("#{@base_url}/guilds/#{guild_id}/threads/active")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.get(url, headers)
  end

  def get_guild_member(guild_id, user_id)
    url = URI("#{@base_url}/guilds/#{guild_id}/members/#{user_id}")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.get(url, headers)
  end

  def list_guild_members(guild_id, limit = nil, after = nil)
    query_string_hash = {}
    query_string_hash[:limit] = limit
    query_string_hash[:after] = after
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = URI("#{@base_url}/guilds/#{guild_id}/members#{query_string}")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.get(url, headers)
  end

  def search_guild_members(guild_id, query, limit = nil)
    query_string_hash = {}
    query_string_hash[:query] = query
    query_string_hash[:limit] = limit
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = URI("#{@base_url}/guilds/#{guild_id}/members/search#{query_string}")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.get(url, headers)
  end

  def add_guild_member(guild_id, user_id, access_token, nick = nil, roles = nil, mute = nil, deaf = nil)
    output = {}
    output[:access_token] = access_token
    output[:nick] = nick unless nick.nil?
    output[:roles] = roles unless roles.nil?
    output[:mute] = mute unless mute.nil?
    output[:deaf] = deaf unless deaf.nil?
    url = URI("#{@base_url}/guilds/#{guild_id}/members/#{user_id}")
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    Net::HTTP.put(url, data, headers)
  end

  def modify_guild_member(guild_id, user_id, nick = nil, roles = nil, mute = nil, deaf = nil, channel_id = nil,
                          communication_disabled_until = nil, flags = nil)
    output = {}
    output[:nick] = nick unless nick.nil?
    output[:roles] = roles unless roles.nil?
    output[:mute] = mute unless mute.nil?
    output[:deaf] = deaf unless deaf.nil?
    output[:channel_id] = channel_id unless channel_id.nil?
    output[:communication_disabled_until] = communication_disabled_until
    output[:flags] = flags unless flags.nil?
    url = URI("#{@base_url}/guilds/#{guild_id}/members/#{user_id}")
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    Net::HTTP.patch(url, data, headers)
  end

  def modify_current_member(guild_id, nick = nil)
    output = {}
    output[:nick] = nick unless nick.nil?
    url = URI("#{@base_url}/guilds/#{guild_id}/members/@me")
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    Net::HTTP.patch(url, data, headers)
  end

  def modify_current_user_nick(guild_id, nick = nil)
    Logger.warn('The "Modify Current User Nick" endpoint has been deprecated and should not be used!')
    output = {}
    output[:nick] = nick unless nick.nil?
    url = URI("#{@base_url}/guilds/#{guild_id}/users/@me/nick")
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    Net::HTTP.patch(url, data, headers)
  end

  def add_guild_member_role(guild_id, user_id, role_id)
    url = URI("#{@base_url}/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.put(url, nil, headers)
  end

  def remove_guild_member_role(guild_id, user_id, role_id)
    url = URI("#{@base_url}/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.delete(url, headers)
  end

  def remove_guild_member(guild_id, user_id)
    url = URI("#{@base_url}/guilds/#{guild_id}/members/#{user_id}")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.delete(url, headers)
  end
end

# frozen_string_literal: true
class DiscordApi
  def create_guild(name, region = nil, icon = nil, verification_level = nil, default_message_notifications = nil, explicit_content_filter = nil, roles = nil, channels = nil, afk_channel_id = nil, afk_timeout = nil, system_channel_id = nil, system_channel_flags = nil)
    output = {}
    output[:name] = name
    output[:region] = region if region != nil
    output[:icon] = icon if icon != nil
    output[:verification_level] = verification_level if verification_level != nil
    output[:default_message_notifications] = default_message_notifications if default_message_notifications != nil
    output[:explicit_content_filter] = explicit_content_filter if explicit_content_filter != nil
    output[:roles] = roles if roles != nil
    output[:channels] = channels if channels != nil
    output[:afk_channel_id] = afk_channel_id if afk_channel_id != nil
    output[:afk_timeout] = afk_timeout if afk_timeout != nil
    output[:system_channel_id] = system_channel_id if system_channel_id != nil
    output[:system_channel_flags] = system_channel_flags if system_channel_flags != nil
    url = URI("#{@base_url}/guilds")
    data = JSON.generate(output)
    headers = {'Authorization': @authorization_header, 'Content-Type': 'application/json'}
    Net::HTTP.post(url, data, headers)
  end

  def get_guild(guild_id, with_counts = nil)
    if with_counts != nil
      url = URI("#{@base_url}/guilds/#{guild_id}?with_counts=#{with_counts}")
    else
      url = URI("#{@base_url}/guilds/#{guild_id}")
    end
    headers = {'Authorization': @authorization_header}
    Net::HTTP.get(url, headers)
  end

  def get_guild_preview(guild_id)
    url = URI("#{@base_url}/guilds/#{guild_id}/preview")
    headers = {'Authorization': @authorization_header}
    Net::HTTP.get(url, headers)
  end

  def modify_guild(guild_id, name = nil, region = nil, verification_level = nil, default_message_notifications = nil, explicit_content_filter = nil, afk_channel_id = nil, afk_timeout = nil, icon = nil, owner_id = nil, splash = nil, discovery_splash = nil, banner = nil, system_channel_id = nil, system_channel_flags = nil, rules_channel_id = nil, public_updates_channel_id = nil, preferred_locale = nil, features = nil, description = nil, premium_progress_bar_enabled = nil, safety_alerts_channel_id = nil)
    output = {}
    output[:name] = name if name != nil
    output[:region] = region if region != nil
    output[:verification_level] = verification_level if verification_level != nil
    output[:default_message_notifications] = default_message_notifications if default_message_notifications != nil
    output[:explicit_content_filter] = explicit_content_filter if explicit_content_filter != nil
    output[:afk_channel_id] = afk_channel_id if afk_channel_id != nil
    output[:afk_timeout] = afk_timeout if afk_timeout != nil
    output[:icon] = icon if icon != nil
    output[:owner_id] = owner_id if owner_id != nil
    output[:splash] = splash if splash != nil
    output[:discovery_splash] = discovery_splash if discovery_splash != nil
    output[:banner] = banner if banner != nil
    output[:system_channel_id] = system_channel_id if system_channel_id != nil
    output[:system_channel_flags] = system_channel_flags if system_channel_flags != nil
    output[:rules_channel_id] = rules_channel_id if rules_channel_id != nil
    output[:public_updates_channel_id] = public_updates_channel_id if public_updates_channel_id != nil
    output[:preferred_locale] = preferred_locale if preferred_locale != nil
    output[:features] = features if features != nil
    output[:description] = description if description != nil
    output[:premium_progress_bar_enabled] = premium_progress_bar_enabled != nil
    output[:safety_alerts_channel_id] = safety_alerts_channel_id if safety_alerts_channel_id != nil
    url = URI("#{@base_url}/guilds/#{guild_id}")
    data = JSON.generate(output)
    headers = {'Authorization': @authorization_header, 'Content-Type': 'application/json'}
    Net::HTTP.patch(url, headers, data)
  end

  def delete_guild(guild_id)
    url = URI("#{@base_url}/guilds/#{guild_id}")
    headers = {'Authorization': @authorization_header}
    Net::HTTP.delete(url, headers)
  end

  def get_guild_channels(guild_id)
    url = URI("#{@base_url}/guilds/#{guild_id}/channels")
    headers = {'Authorization': @authorization_header}
    Net::HTTP.get(url, headers)
  end

  def create_guild_channel(guild_id, name, type = nil, topic = nil, bitrate = nil, user_limit = nil, rate_limit_per_user = nil, position = nil, permission_overwrites = nil, parent_id = nil, nsfw = nil, rtc_region = nil, video_quality_mode = nil, default_auto_archive_duration = nil, default_reaction_emoji = nil, available_tags = nil, default_sort_order = nil, default_forum_layout = nil, default_thread_rate_limit_per_user = nil)
    output = {}
    output[:name] = name
    output[:type] = type if type != nil
    output[:topic] = topic if topic != nil
    output[:bitrate] = bitrate if user_limit != nil
    output[:user_limit] = user_limit if user_limit != nil
    output[:rate_limit_per_user] = rate_limit_per_user if rate_limit_per_user != nil
    output[:position] = position if position != nil
    output[:permission_overwrites] = permission_overwrites if permission_overwrites != nil
    output[:parent_id] = parent_id if parent_id != nil
    output[:nsfw] = nsfw if nsfw != nil
    output[:rtc_region] = rtc_region if rtc_region != nil
    output[:video_quality_mode] = video_quality_mode if video_quality_mode != nil
    output[:default_auto_archive_duration] = default_auto_archive_duration if default_auto_archive_duration != nil
    output[:default_reaction_emoji] = default_reaction_emoji if default_reaction_emoji != nil
    output[:available_tags] = available_tags if available_tags != nil
    output[:default_sort_order] = default_sort_order if default_sort_order != nil
    output[:default_forum_layout] = default_forum_layout if default_forum_layout != nil
    output[:default_thread_rate_limit_per_user] = default_thread_rate_limit_per_user if default_thread_rate_limit_per_user != nil
    url = URI("#{@base_url}/guilds/#{guild_id}/channels")
    data = JSON.generate(output)
    headers = {'Authorization': @authorization_header, 'Content-Type': 'application/json'}
    Net::HTTP.post(url, data, headers)
  end

  def get_guild_member(guild_id, user_id)
    url = URI("#{@base_url}/guilds/#{guild_id}/members/#{user_id}")
    headers = {'Authorization': @authorization_header}
    Net::HTTP.get(url, headers)
  end

  def list_guild_members(guild_id)
    url = URI("#{@base_url}/guilds/#{guild_id}/members")
    headers = {'Authorization': @authorization_header}
    Net::HTTP.get(url, headers)
  end
end
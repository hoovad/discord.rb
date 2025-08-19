# frozen_string_literal: true

# DiscordApi
# The class that contains everything that interacts with the Discord API.
class DiscordApi
  def create_guild(name, region: nil, icon: nil, verification_level: nil, default_message_notifications: nil,
                   explicit_content_filter: nil, roles: nil, channels: nil, afk_channel_id: nil, afk_timeout: nil,
                   system_channel_id: nil, system_channel_flags: nil)
    output = {}
    output[:name] = name
    unless region.nil?
      @logger.warn('The "region" parameter has been deprecated and should not be used!')
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
    url = "#{@base_url}/guilds"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.post(url, data, headers)
    return response if response.status == 200

    @logger.error("Could not create guild. Response: #{response.body}")
    response
  end

  def get_guild(guild_id, with_counts = nil)
    query_string_hash = {}
    query_string_hash[:with_counts] = with_counts unless with_counts.nil?
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = "#{@base_url}/guilds/#{guild_id}#{query_string}"
    headers = { 'Authorization' => @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Could not get guild with Guild ID #{guild_id}. Response: #{response.body}")
    response
  end

  def get_guild_preview(guild_id)
    url = URI("#{@base_url}/guilds/#{guild_id}/preview")
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Could not get guild preview with Guild ID #{guild_id}. Response: #{response.body}")
    response
  end

  def modify_guild(guild_id, name: nil, region: nil, verification_level: nil, default_message_notifications: nil,
                   explicit_content_filter: nil, afk_channel_id: nil, afk_timeout: nil, icon: nil, owner_id: nil,
                   splash: nil, discovery_splash: nil, banner: nil, system_channel_id: nil,
                   system_channel_flags: nil, rules_channel_id: nil, public_updates_channel_id: nil,
                   preferred_locale: nil, features: nil, description: nil, premium_progress_bar_enabled: nil,
                   safety_alerts_channel_id: nil, audit_reason: nil)
    if args[1..-2].all?(&:nil?)
      @logger.warn("No modifications for guild with ID #{guild_id} provided. Skipping.")
      return nil
    end
    output = {}
    output[:name] = name unless name.nil?
    unless region.nil?
      @logger.warn('The "region" parameter has been deprecated and should not be used!')
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
    output[:premium_progress_bar_enabled] = premium_progress_bar_enabled unless premium_progress_bar_enabled.nil?
    output[:safety_alerts_channel_id] = safety_alerts_channel_id unless safety_alerts_channel_id.nil?
    url = "#{@base_url}/guilds/#{guild_id}"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.patch(url, headers, data)
    return response if response.status == 200

    @logger.error("Could not modify guild with Guild ID #{guild_id}. Response: #{response.body}")
    response
  end

  def delete_guild(guild_id)
    url = "#{@base_url}/guilds/#{guild_id}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.delete(url, headers)
    return response if response.status == 204

    @logger.error("Could not delete guild with Guild ID #{guild_id}. Response: #{response.body}")
    response
  end

  def get_guild_channels(guild_id)
    url = "#{@base_url}/guilds/#{guild_id}/channels"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Could not get guild channels with Guild ID #{guild_id}. Response: #{response.body}")
    response
  end

  def create_guild_channel(guild_id, name, type: nil, topic: nil, bitrate: nil, user_limit: nil,
                           rate_limit_per_user: nil, position: nil, permission_overwrites: nil, parent_id: nil,
                           nsfw: nil, rtc_region: nil, video_quality_mode: nil, default_auto_archive_duration: nil,
                           default_reaction_emoji: nil, available_tags: nil, default_sort_order: nil,
                           default_forum_layout: nil, default_thread_rate_limit_per_user: nil, audit_reason: nil)
    output = {}
    output[:name] = name
    output[:type] = type unless type.nil?
    output[:topic] = topic unless topic.nil?
    output[:bitrate] = bitrate unless bitrate.nil?
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
      output[:default_thread_rate_limit_per_user] = default_thread_rate_limit_per_user
    end
    url = "#{@base_url}/guilds/#{guild_id}/channels"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.post(url, data, headers)
    return response if response.status == 200

    @logger.error("Could not create guild channel in Guild ID #{guild_id}. Response: #{response.body}")
    response
  end

  def modify_guild_channel_positions(guild_id, channel_id, position: nil, lock_permissions: nil, parent_id: nil)
    if args[2..].all?(&:nil?)
      @logger.warn("No modifications for guild channel positions with guild ID #{guild_id} and channel ID " \
                     "#{channel_id} provided. Skipping.")
      return nil
    end
    output = {}
    output[:id] = channel_id
    output[:position] = position unless position.nil?
    output[:lock_permissions] = lock_permissions unless lock_permissions.nil?
    output[:parent_id] = parent_id unless parent_id.nil?
    url = "#{@base_url}/guilds/#{guild_id}/channels"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.patch(url, headers, data)
    return response if response.status == 200

    @logger.error("Could not modify guild channel positions with Guild ID #{guild_id}. Response: #{response.body}")
    response
  end

  def list_active_guild_threads(guild_id)
    url = "#{@base_url}/guilds/#{guild_id}/threads/active"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Could not list active guild threads with Guild ID #{guild_id}. Response: #{response.body}")
    response
  end

  def get_guild_member(guild_id, user_id)
    url = "#{@base_url}/guilds/#{guild_id}/members/#{user_id}"
    headers = { 'Authorization' => @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Could not get guild member with Guild ID #{guild_id} and User ID #{user_id}. Response:" \
                   "#{response.body}")
    response
  end

  def list_guild_members(guild_id, limit: nil, after: nil)
    query_string_hash = {}
    query_string_hash[:limit] = limit unless limit.nil?
    query_string_hash[:after] = after unless after.nil?
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = "#{@base_url}/guilds/#{guild_id}/members#{query_string}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Could not list members with Guild ID #{guild_id}. Response: #{response.body}")
    response
  end

  def search_guild_members(guild_id, query, limit = nil)
    query_string_hash = {}
    query_string_hash[:query] = query
    query_string_hash[:limit] = limit unless limit.nil?
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = "#{@base_url}/guilds/#{guild_id}/members/search#{query_string}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Could not search members with Guild ID #{guild_id}. Response: #{response.body}")
    response
  end

  def add_guild_member(guild_id, user_id, access_token, nick: nil, roles: nil, mute: nil, deaf: nil)
    output = {}
    output[:access_token] = access_token
    output[:nick] = nick unless nick.nil?
    output[:roles] = roles unless roles.nil?
    output[:mute] = mute unless mute.nil?
    output[:deaf] = deaf unless deaf.nil?
    url = "#{@base_url}/guilds/#{guild_id}/members/#{user_id}"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.put(url, data, headers)
    if response.status == 204
      @logger.warn("User with ID #{user_id} is already a member of the guild with ID #{guild_id}.")
    elsif response.status == 201
      @logger.info("Added user with ID #{user_id} to guild with ID #{guild_id}.")
    else
      @logger.error("Could not add user with ID #{user_id} to guild with ID #{guild_id}. Response: #{response.body}")
    end
    response
  end

  def modify_guild_member(guild_id, user_id, nick: nil, roles: nil, mute: nil, deaf: nil, channel_id: nil,
                          communication_disabled_until: nil, flags: nil, audit_reason: nil)
    if args[2..-2].all?(&:nil?)
      @logger.warn("No modifications for guild member with guild ID #{guild_id} and user ID #{user_id} provided. " \
                     'Skipping.')
      return nil
    end
    output = {}
    output[:nick] = nick unless nick.nil?
    output[:roles] = roles unless roles.nil?
    output[:mute] = mute unless mute.nil?
    output[:deaf] = deaf unless deaf.nil?
    output[:channel_id] = channel_id unless channel_id.nil?
    output[:communication_disabled_until] = communication_disabled_until unless communication_disabled_until.nil?
    output[:flags] = flags unless flags.nil?
    url = "#{@base_url}/guilds/#{guild_id}/members/#{user_id}"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.patch(url, data, headers)
    return response if response.status == 200

    @logger.error("Could not modify guild member with Guild ID #{guild_id} and User ID #{user_id}. " \
    "Response: #{response.body}")
    response
  end

  def modify_current_member(guild_id, nick: nil, audit_reason: nil)
    if nick.nil?
      @logger.warn("No modifications for current member in guild ID #{guild_id} provided. Skipping.")
      return nil
    end
    output = {}
    output[:nick] = nick unless nick.nil?
    url = "#{@base_url}/guilds/#{guild_id}/members/@me"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.patch(url, data, headers)
    return response if response.status == 200

    @logger.error("Could not modify current member in guild with Guild ID #{guild_id}. Response: #{response.body}")
    response
  end

  def modify_current_user_nick(guild_id, nick: nil, audit_reason: nil)
    @logger.warn('The "Modify Current User Nick" endpoint has been deprecated and should not be used!')
    if nick.nil?
      @logger.warn("No modifications for current user nick in guild ID #{guild_id} provided. Skipping.")
      return nil
    end
    output = {}
    output[:nick] = nick unless nick.nil?
    url = "#{@base_url}/guilds/#{guild_id}/users/@me/nick"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.patch(url, data, headers)
    return response if response.status == 200

    @logger.error("Could not modify current user nick in guild with ID #{guild_id}. Response: #{response.body}")
    response
  end

  def add_guild_member_role(guild_id, user_id, role_id, audit_reason = nil)
    url = "#{@base_url}/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}"
    headers = { 'Authorization': @authorization_header }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.put(url, nil, headers)
    return response if response.status == 204

    @logger.error("Could not add role with ID #{role_id}, to user with ID #{user_id} in guild with ID #{guild_id}." \
                   " Response: #{response.body}")
    response
  end

  def remove_guild_member_role(guild_id, user_id, role_id, audit_reason = nil)
    url = "#{@base_url}/guilds/#{guild_id}/members/#{user_id}/roles/#{role_id}"
    headers = { 'Authorization': @authorization_header }
    headers['x-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.delete(url, headers)
    return response if response.status == 204

    @logger.error("Could not remove role with ID #{role_id}, from user with ID #{user_id}" \
                  " in guild with ID #{guild_id}. Response: #{response.body}")
    response
  end

  def remove_guild_member(guild_id, user_id, audit_reason = nil)
    url = "#{@base_url}/guilds/#{guild_id}/members/#{user_id}"
    headers = { 'Authorization' => @authorization_header }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.delete(url, headers)
    return response if response.status == 204

    @logger.error("Could not remove user with ID #{user_id} from guild with ID #{guild_id}. Response: #{response.body}")
    response
  end

  def get_guild_bans(guild_id, limit: nil, before: nil, after: nil)
    query_string_hash = {}
    query_string_hash[:limit] = limit unless limit.nil?
    query_string_hash[:before] = before unless before.nil?
    query_string_hash[:after] = after unless after.nil?
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = "#{@base_url}/guilds/#{guild_id}/bans#{query_string}"
    headers = { 'Authorization' => @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Could not get guild bans with Guild ID #{guild_id}. Response: #{response.body}")
    response
  end

  def get_guild_ban(guild_id, user_id)
    url = "#{@base_url}/guilds/#{guild_id}/bans/#{user_id}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    if response.status == 404
      @logger.warn("No ban found for user with ID #{user_id} in guild with ID #{guild_id}.")
    else
      @logger.error("Could not get guild ban for user with ID #{user_id} in guild with ID #{guild_id}." \
                     " Response: #{response.body}")
    end
    response
  end

  def create_guild_ban(guild_id, user_id, delete_message_days: nil, delete_message_seconds: nil, audit_reason: nil)
    output = {}
    unless delete_message_days.nil?
      @logger.warn('The "delete_message_days" parameter has been deprecated and should not be used!')
      output[:delete_message_days] = delete_message_days
    end
    output[:delete_message_seconds] = delete_message_seconds unless delete_message_seconds.nil?
    url = "#{@base_url}/guilds/#{guild_id}/bans/#{user_id}"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.put(url, data, headers)
    return response if response.status == 204

    @logger.error("Could not create guild ban for user with ID #{user_id} in guild with ID #{guild_id}." \
                   " Response: #{response.body}")
    response
  end

  def remove_guild_ban(guild_id, user_id, audit_reason = nil)
    url = "#{@base_url}/guilds/#{guild_id}/bans/#{user_id}"
    headers = { 'Authorization': @authorization_header }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.delete(url, headers)
    return response if response.status == 204

    @logger.error("Could not remove guild ban for user with ID #{user_id} in guild with ID #{guild_id}" \
                  " Response: #{response.body}")
    response
  end

  def bulk_guild_ban(guild_id, user_ids, delete_message_seconds: nil, audit_reason: nil)
    output = {}
    output[:user_ids] = user_ids unless user_ids.nil?
    output[:delete_message_seconds] = delete_message_seconds unless delete_message_seconds.nil?
    url = "#{@base_url}/guilds/#{guild_id}/bulk-ban"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.post(url, data, headers)
    return response if response.status == 200

    if response.status == 500_000
      @logger.error("No users were banned in bulk ban in guild with ID #{guild_id}. Response: #{response.body}")
    else
      @logger.error("Could not bulk ban users in guild with ID #{guild_id}. Response: #{response.body}")
    end
    response
  end

  def get_guild_roles(guild_id)
    url = "#{@base_url}/guilds/#{guild_id}/roles"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Could not get guild roles with Guild ID #{guild_id}. Response: #{response.body}")
    response
  end

  def get_guild_role(guild_id, role_id)
    url = "#{@base_url}/guilds/#{guild_id}/roles/#{role_id}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Could not get role with ID #{role_id} in guild with ID #{guild_id}. Response: #{response.body}")
    response
  end

  def create_guild_role(guild_id, name: nil, permissions: nil, color: nil, colors: nil, hoist: nil, icon: nil,
                        unicode_emoji: nil, mentionable: nil, audit_reason: nil)
    output = {}
    output[:name] = name unless name.nil?
    output[:permissions] = permissions unless permissions.nil?
    unless color.nil?
      @logger.warn('The "color" parameter has been deprecated and should not be used!')
      output[:color] = color
    end
    output[:colors] = colors unless colors.nil?
    output[:hoist] = hoist unless hoist.nil?
    output[:icon] = icon unless icon.nil?
    output[:unicode_emoji] = unicode_emoji unless unicode_emoji.nil?
    output[:mentionable] = mentionable unless mentionable.nil?
    url = "#{@base_url}/guilds/#{guild_id}/roles"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.post(url, data, headers)
    return response if response.status == 200

    @logger.error("Could not create guild role in guild with ID #{guild_id}. Response: #{response.body}")
    response
  end

  def modify_guild_role_positions(guild_id, id, position: nil, audit_reason: nil)
    if position.nil?
      @logger.warn("No role positions provided for guild with ID #{guild_id}. Skipping function.")
      return nil
    end
    output = {}
    output[:id] = id
    output[:position] = position unless position.nil?
    url = "#{@base_url}/guilds/#{guild_id}/roles"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.patch(url, data, headers)
    return response if response.status == 200

    @logger.error("Could not modify guild role positions in guild with ID #{guild_id}. Response: #{response.body}")
    response
  end

  def modify_guild_role(guild_id, role_id, name: nil, permissions: nil, color: nil, hoist: nil, icon: nil,
                        unicode_emoji: nil, mentionable: nil, audit_reason: nil)
    if args[2..-2].all?(&:nil?)
      @logger.warn("No modifications for guild role with ID #{role_id} in guild with ID #{guild_id} provided. " \
                     'Skipping.')
      return nil
    end
    output = {}
    output[:name] = name unless name.nil?
    output[:permissions] = permissions unless permissions.nil?
    output[:color] = color unless color.nil?
    output[:hoist] = hoist unless hoist.nil?
    output[:icon] = icon unless icon.nil?
    output[:unicode_emoji] = unicode_emoji unless unicode_emoji.nil?
    output[:mentionable] = mentionable unless mentionable.nil?
    url = "#{@base_url}/guilds/#{guild_id}/roles/#{role_id}"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.patch(url, data, headers)
    return response if response.status == 200

    @logger.error("Could not modify guild role with ID #{role_id} in guild with ID #{guild_id}." \
                 " Response: #{response.body}")
    response
  end

  def modify_guild_mfa_level(guild_id, level, audit_reason = nil)
    output = {}
    output[:level] = level
    url = "#{@base_url}/guilds/#{guild_id}/mfa"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.post(url, data, headers)
    return unless response.status != 200

    @logger.error("Failed to modify guild MFA level. Response: #{response.body}")
    response
  end

  def delete_guild_role(guild_id, role_id, audit_reason = nil)
    url = "#{@base_url}/guilds/#{guild_id}/roles/#{role_id}"
    headers = { 'Authorization': @authorization_header }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.delete(url, headers)
    return response if response.status == 204

    @logger.error("Failed to delete guild role. Response: #{response.body}")
    response
  end

  def get_guild_prune_count(guild_id, days: nil, include_roles: nil)
    query_string_hash = {}
    query_string_hash[:days] = days unless days.nil?
    query_string_hash[:include_roles] = include_roles unless include_roles.nil?
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = "#{@base_url}/guilds/#{guild_id}/prune#{query_string}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get guild prune count. Response: #{response.body}")
    response
  end

  def begin_guild_prune(guild_id, days: nil, compute_prune_count: nil, include_roles: nil, reason: nil,
                        audit_reason: nil)
    output = {}
    output[:days] = days unless days.nil?
    output[:compute_prune_count] = compute_prune_count unless compute_prune_count.nil?
    output[:include_roles] = include_roles unless include_roles.nil?
    unless reason.nil?
      @logger.warn('The "reason" parameter has been deprecated and should not be used!')
      output[:reason] = reason
    end
    url = "#{@base_url}/guilds/#{guild_id}/prune"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.post(url, data, headers)
    return response if response.status == 200

    @logger.error("Failed to begin guild prune. Response: #{response.body}")
    response
  end

  def get_guild_voice_regions(guild_id)
    url = "#{@base_url}/guilds/#{guild_id}/regions"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get guild voice regions. Response: #{response.body}")
    response
  end

  def get_guild_invites(guild_id)
    url = "#{@base_url}/guilds/#{guild_id}/invites"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get guild invites. Response: #{response.body}")
    response
  end

  def get_guild_integrations(guild_id)
    url = "#{@base_url}/guilds/#{guild_id}/integrations"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    if response.status == 200
      if JSON.parse(response.body).length == 50
        @logger.warn('The endpoint returned 50 integrations, which means there could be more integrations not shown.')
      end
      return response
    end

    @logger.error("Failed to get guild integrations. Response: #{response.body}")
    response
  end

  def delete_guild_integration(guild_id, integration_id, audit_reason = nil)
    url = "#{@base_url}/guilds/#{guild_id}/integrations/#{integration_id}"
    headers = { 'Authorization': @authorization_header }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.delete(url, headers)
    return response if response.status == 204

    @logger.error("Failed to delete guild integration. Response: #{response.body}")
    response
  end

  def get_guild_widget_settings(guild_id)
    url = "#{@base_url}/guilds/#{guild_id}/widget"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get guild widget settings. Response: #{response.body}")
    response
  end

  def modify_guild_widget(guild_id, enabled, channel_id, audit_reason: nil)
    output = {}
    output[:enabled] = enabled
    output[:channel_id] = channel_id
    url = "#{@base_url}/guilds/#{guild_id}/widget"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.patch(url, data, headers)
    return response if response.status == 200

    @logger.error("Failed to modify guild widget. Response: #{response.body}")
    response
  end

  def get_guild_wiget(guild_id)
    url = "#{@base_url}/guilds/#{guild_id}/widget.json"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get guild widget. Response: #{response.body}")
    response
  end

  def get_guild_vanity_url(guild_id)
    url = "#{@base_url}/guilds/#{guild_id}/vanity-url"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get guild vanity URL. Response: #{response.body}")
    response
  end

  def get_guild_widget_image(guild_id, shield: false, banner1: false, banner2: false, banner3: false, banner4: false)
    options = { shield: shield, banner1: banner1, banner2: banner2, banner3: banner3, banner4: banner4 }
    true_keys = options.select { |_k, v| v }.keys

    if true_keys.size > 1
      @logger.error('You can only specify one of shield, banner1, banner2, banner3, or banner4 as true.')
      nil
    elsif true_keys.size == 1
      style = true_keys.first.to_s
    else
      style = nil
    end

    query_string_hash = {}
    query_string_hash[:style] = style unless style.nil?
    query_string = DiscordApi.handle_query_strings(query_string_hash)

    url = "#{@base_url}/guilds/#{guild_id}/widget.png#{query_string}"
    response = DiscordApi.get(url)
    return unless response.status != 200

    @logger.error("Failed to get guild widget image. Response: #{response.body}")
    response
  end

  def get_guild_welcome_screen(guild_id)
    url = "#{@base_url}/guilds/#{guild_id}/welcome-screen"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get guild welcome screen. Response: #{response.body}")
    response
  end

  def modify_guild_welcome_screen(guild_id, enabled: nil, welcome_channels: nil, description: nil,
                                  audit_reason: nil)
    if args[1..-2].all?(&:nil?)
      @logger.warn("No modifications for guild welcome screen with guild ID #{guild_id} provided. " \
                     'Skipping.')
      return nil
    end
    output = {}
    output[:enabled] = enabled unless enabled.nil?
    output[:welcome_channels] = welcome_channels unless welcome_channels.nil?
    output[:description] = description unless description.nil?
    url = "#{@base_url}/guilds/#{guild_id}/welcome-screen"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.patch(url, data, headers)
    return response if response.status == 200

    @logger.error("Failed to modify guild welcome screen. Response: #{response.body}")
    response
  end

  def get_guild_onboarding(guild_id)
    url = "#{@base_url}/guilds/#{guild_id}/onboarding"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get guild onboarding. Response: #{response.body}")
    response
  end

  def modify_guild_onboarding(guild_id, prompts: nil, default_channel_ids: nil, enabled: nil, mode: nil,
                              audit_reason: nil)
    if args[1..-2].all?(&:nil?)
      @logger.warn("No modifications for guild onboarding with guild ID #{guild_id} provided. " \
                     'Skipping.')
      return nil
    end
    output = {}
    output[:prompts] = prompts unless prompts.nil?
    output[:default_channel_ids] = default_channel_ids unless default_channel_ids.nil?
    output[:enabled] = enabled unless enabled.nil?
    output[:mode] = mode unless mode.nil?
    url = "#{@base_url}/guilds/#{guild_id}/onboarding"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers['X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.put(url, data, headers)
    return response if response.status == 200

    @logger.error("Failed to modify guild onboarding. Response: #{response.body}")
    response
  end

  def modify_guild_incident_actions(guild_id, invites_disabled_until: nil, dms_disabled_until: nil)
    if args[1..].all?(&:nil?)
      @logger.warn("No modifications for guild incident actions with guild ID #{guild_id} provided. " \
                     'Skipping.')
      return nil
    end
    output = {}
    if invites_disabled_until == false
      output[:invites_disabled_until] = nil
    elsif !invites_disabled_until.nil?
      output[:invites_disabled_until] = invites_disabled_until
    end
    if dms_disabled_until == false
      output[:dms_disabled_until] = nil
    elsif !dms_disabled_until.nil?
      output[:dms_disabled_until] = dms_disabled_until
    end
    url = "#{@base_url}/guilds/#{guild_id}/incident-actions"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.put(url, data, headers)
    return response if response.status == 200

    @logger.error("Failed to modify guild incident actions. Response: #{response.body}")
    response
  end
end

# frozen_string_literal: true

# DiscordApi
# The class that contains everything that interacts with the Discord API.
class DiscordApi
  def get_channel_messages(channel_id, around: nil, before: nil, after: nil, limit: nil)
    options = { around: around, before: before, after: after }
    specified_keys = options.reject { |_k, v| v.nil? }.keys

    if specified_keys.size > 1
      @logger.error('You can only specify one of around, before or after. Setting all to nil.')
      around, before, after = nil
    elsif specified_keys.size == 1
      instance_variable_set("@#{specified_keys.first}", options[specified_keys.first])
    end

    query_string_hash = {}
    query_string_hash[:around] = around unless around.nil?
    query_string_hash[:before] = before unless before.nil?
    query_string_hash[:after] = after unless after.nil?
    query_string_hash[:limit] = limit unless limit.nil?
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = "#{@base_url}/channels/#{channel_id}/messages#{query_string}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response unless response.status != 200

    @logger.error("Failed to get messages from channel with ID #{channel_id}. Response: #{response.body}")
    response
  end

  def get_channel_message(channel_id, message_id)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response unless response.status != 200

    @logger.error("Failed to get message with ID #{message_id} from channel with ID #{channel_id}. " \
                    "Response: #{response.body}")
    response
  end

  def create_message(channel_id, content: nil, nonce: nil, tts: nil, embeds: nil, allowed_mentions: nil,
                     message_reference: nil, components: nil, sticker_ids: nil, files: nil, attachments: nil,
                     flags: nil, enforce_nonce: nil, poll: nil)
    if content.nil? && embeds.nil? && sticker_ids.nil? && components.nil? && files.nil? && poll.nil?
      @logger.warn('No content, embeds, sticker ids, components, files or poll provided. Skipping function.')
      return
    end
    output = {}
    output[:content] = content unless content.nil?
    output[:nonce] = nonce unless nonce.nil?
    output[:tts] = tts unless tts.nil?
    output[:embeds] = embeds unless embeds.nil?
    output[:allowed_mentions] = allowed_mentions unless allowed_mentions.nil?
    output[:message_reference] = message_reference unless message_reference.nil?
    output[:components] = components unless components.nil?
    output[:sticker_ids] = sticker_ids unless sticker_ids.nil?
    output[:files] = files unless files.nil?
    output[:attachments] = attachments unless attachments.nil?
    output[:flags] = flags unless flags.nil?
    output[:enforce_nonce] = enforce_nonce unless enforce_nonce.nil?
    output[:poll] = poll unless poll.nil?
    url = "#{@base_url}/channels/#{channel_id}/messages"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.post(url, data, headers)
    return response unless response.status != 200

    @logger.error("Failed to create message in channel #{channel_id}. Response: #{response.body}")
    response
  end

  def crosspost_message(channel_id, message_id)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}/crosspost"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.post(url, nil, headers)
    return response unless response.status != 200

    @logger.error("Failed to crosspost message with ID #{message_id} in channel with ID #{channel_id}. " \
                    "Response: #{response.body}")
    response
  end

  def create_reaction(channel_id, message_id, emoji_id)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji_id}/@me"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.put(url, nil, headers)
    return response unless response.status != 204

    @logger.error("Failed to create reaction with emoji ID #{emoji_id} in channel with ID #{channel_id} " \
                    "for message with ID #{message_id}. Response: #{response.body}")
    response
  end

  def delete_own_reaction(channel_id, message_id, emoji_id)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji_id}/@me"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.delete(url, headers)
    return response unless response.status != 204

    @logger.error("Failed to delete own reaction with emoji ID #{emoji_id} in channel with ID #{channel_id} " \
                    "for message with ID #{message_id}. Response: #{response.body}")
    response
  end

  def delete_user_reaction(channel_id, message_id, emoji_id, user_id)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji_id}/#{user_id}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.delete(url, headers)
    return response unless response.status != 204

    @logger.error("Failed to delete user reaction with emoji ID #{emoji_id} in channel with ID #{channel_id} " \
                    "for message with ID #{message_id} by user with ID #{user_id}. Response: #{response.body}")
    response
  end

  def get_reactions(channel_id, message_id, emoji_id, type: nil, after: nil, limit: nil)
    query_string_hash = {}
    query_string_hash[:type] = type unless type.nil?
    query_string_hash[:after] = after unless after.nil?
    query_string_hash[:limit] = limit unless limit.nil?
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji_id}#{query_string}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response unless response.status != 200

    @logger.error("Failed to get reactions for emoji with ID #{emoji_id} in channel with ID #{channel_id} " \
                    "for message with ID #{message_id}. Response: #{response.body}")
    response
  end

  def delete_all_reactions(channel_id, message_id)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}/reactions"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.delete(url, headers)
    return response unless response.status != 204

    @logger.error("Failed to delete all reactions in channel with ID #{channel_id} for message with ID #{message_id}" \
                    ". Response: #{response.body}")
  end

  def delete_all_reactions_for_emoji(channel_id, message_id, emoji_id)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji_id}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.delete(url, headers)
    return response unless response.status != 204

    @logger.error("Failed to delete all reactions for emoji with ID #{emoji_id} in channel with ID #{channel_id} for " \
                    "message with ID #{message_id}. Response: #{response.body}")
  end

  def edit_message(channel_id, message_id, content: nil, embeds: nil, flags: nil, allowed_mentions: nil,
                   components: nil, files: nil, payload_json: nil, attachments: nil)
    if args[2..].all?(&:nil?)
      @logger.warn("No modifications provided for message with ID #{message_id} in channel with ID #{channel_id}. " \
                     'Skipping function.')
      return nil
    end
    output = {}
    output[:content] = content unless content.nil?
    output[:embeds] = embeds unless embeds.nil?
    output[:flags] = flags unless flags.nil?
    output[:allowed_mentions] = allowed_mentions unless allowed_mentions.nil?
    output[:components] = components unless components.nil?
    output[:files] = files unless files.nil?
    output[:payload_json] = payload_json unless payload_json.nil?
    output[:attachments] = attachments unless attachments.nil?
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.patch(url, data, headers)
    return response unless response.status != 200

    @logger.error("Failed to edit message with ID #{message_id} in channel with ID #{channel_id}. " \
                    "Response: #{response.body}")
    response
  end

  def delete_message(channel_id, message_id, audit_reason = nil)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}"
    headers = { 'Authorization': @authorization_header }
    headers[:'X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.delete(url, headers)
    return response unless response.status != 204

    @logger.error("Failed to delete message with ID #{message_id} in channel with ID #{channel_id}. " \
                    "Response: #{response.body}")
    response
  end

  def bulk_delete_messages(channel_id, messages, audit_reason = nil)
    output = { messages: messages }
    url = "#{@base_url}/channels/#{channel_id}/messages/bulk-delete"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers[:'X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.post(url, data, headers)
    return response unless response.status != 204

    @logger.error("Failed to bulk delete messages in channel with ID #{channel_id}. Response: #{response.body}")
    response
  end

  def get_channel_pins(channel_id, before: nil, limit: nil)
    query_string_hash = {}
    query_string_hash[:before] = before unless before.nil?
    query_string_hash[:limit] = limit unless limit.nil?
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = "#{@base_url}/channels/#{channel_id}/messages/pins#{query_string}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response unless response.status != 200

    @logger.error("Failed to get pinned messages in channel with ID #{channel_id}. Response: #{response.body}")
    response
  end

  def pin_message(channel_id, message_id, audit_reason = nil)
    url = "#{@base_url}/channels/#{channel_id}/messages/pins/#{message_id}"
    headers = { 'Authorization': @authorization_header }
    headers[:'X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.put(url, nil, headers)
    return response unless response.status != 204

    @logger.error("Failed to pin message with ID #{message_id} in channel with ID #{channel_id}. " \
                    "Response: #{response.body}")
    response
  end

  def unpin_message(channel_id, message_id, audit_reason = nil)
    url = "#{@base_url}/channels/#{channel_id}/messages/pins/#{message_id}"
    headers = { 'Authorization': @authorization_header }
    headers[:'X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.delete(url, headers)
    return response unless response.status != 204

    @logger.error("Failed to unpin message with ID #{message_id} in channel with ID #{channel_id}. " \
                    "Response: #{response.body}")
    response
  end
end

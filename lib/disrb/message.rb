# frozen_string_literal: true

# Class that contains functions that allow interacting with the Discord API.
class DiscordApi
  # Gets the messages in a channel. Returns an array of message objects from newest to oldest on success.
  # See https://discord.com/developers/docs/resources/message#get-channel-messages
  #
  # The before, after, and around parameters are mutually exclusive. Only one of them can be specified.
  # If more than one of these are specified, all of these will be set to nil and an error will be logged
  # (depends on the verbosity level set).
  # @param channel_id [String] The ID of the channel to get messages from.
  # @param around [String, nil] Gets messages around the specified message ID.
  # @param before [String, nil] Gets messages before the specified message ID.
  # @param after [String, nil] Gets messages after the specified message ID.
  # @param limit [Integer, nil] The maximum number of messages to return. Default 50.
  # @return [Faraday::Response] The response from the Discord API as a Farday::Response object.
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
    return response if response.status == 200

    @logger.error("Failed to get messages from channel with ID #{channel_id}. Response: #{response.body}")
    response
  end

  # Gets a specific message from a channel. Returns a message object on success.
  # See https://discord.com/developers/docs/resources/message#get-channel-message
  # @param channel_id [String] The ID of the channel to get the message from.
  # @param message_id [String] The ID of the message to get.
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def get_channel_message(channel_id, message_id)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get message with ID #{message_id} from channel with ID #{channel_id}. " \
                    "Response: #{response.body}")
    response
  end

  # Creates a message in a channel. Returns the created message object on success.
  # See https://discord.com/developers/docs/resources/message#create-message
  # One of content, embeds, sticker_ids, components or poll must be provided. If none of these are provided,
  # the function will log a warning (depends on the verbosity level set) and return nil
  # @param channel_id [String] The ID of the channel to create the message in
  # @param content [String, nil] Message contents (up to 2000 characters)
  # @param nonce [String, Integer, nil] Can be used to verify if a message was sent (up to 25 characters). The value
  #   will appear in the message object,
  # @param tts [TrueClass, FalseClass, nil] Whether the message is a TTS message
  # @param embeds [Array, nil] Up to 10 rich embeds (up to 6000 characters)
  # @param allowed_mentions [Hash, nil] Allowed mentions object
  # @param message_reference [Hash, nil] Message reference object for replies/forwards
  # @param components [Array, nil] An array of Components to include with the message
  # @param sticker_ids [Array, nil] IDs of up to 3 stickers in the server to send in the message
  # @param _files [nil] WORK IN PROGRESS
  # @param attachments [Array, nil] Attachments objects with filename and description. Practically useless due to
  #   uploading files not being implemented yet.
  # @param flags [Integer, nil] Message flags combined as a bitfield.
  # @param enforce_nonce [TrueClass, FalseClass, nil] If true and a nonce is set, the nonce's uniqueness will be
  #   checked, if a message with the same nonce already exists from the same author, that message will be returned
  #   and no new message will be created.
  # @param poll [Hash, nil] A poll object
  # @return [Faraday::Response, nil] The response from the Discord API as a Faraday::Response object, or nil if none of
  #   content, embeds, sticker_ids, components or poll were provided.
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
    return response if response.status == 200

    @logger.error("Failed to create message in channel #{channel_id}. Response: #{response.body}")
    response
  end

  # Crossposts a message in an Announcement Channel to all following channels. Returns the crossposted message object on
  # success. See https://discord.com/developers/docs/resources/message#crosspost-message
  # @param channel_id [String] The ID of the channel the message to crosspost is located
  # @param message_id [String] The ID of the message to crosspost
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def crosspost_message(channel_id, message_id)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}/crosspost"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.post(url, nil, headers)
    return response if response.status == 200

    @logger.error("Failed to crosspost message with ID #{message_id} in channel with ID #{channel_id}. " \
                    "Response: #{response.body}")
    response
  end

  def create_reaction(channel_id, message_id, emoji_id)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji_id}/@me"
  # Create a reaction for the specified message. Returns no content on success.
  # See https://discord.com/developers/docs/resources/message#create-reaction
  # @param channel_id [String] The ID of the channel the message is located in
  # @param message_id [String] The ID of the message to create the reaction for
  # @param emoji [String] URL encoded emoji to react with, or name:id format for custom emojis
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.put(url, nil, headers)
    return response if response.status == 204

    @logger.error("Failed to create reaction with emoji ID #{emoji_id} in channel with ID #{channel_id} " \
                    "for message with ID #{message_id}. Response: #{response.body}")
    response
  end

  def delete_own_reaction(channel_id, message_id, emoji_id)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji_id}/@me"
  # Deletes a reaction with the specified emoji for the current user in the specified message. Returns no content on
  # success. See https://discord.com/developers/docs/resources/message#delete-own-reaction
  # @param channel_id [String] The ID of the channel the message is located in
  # @param message_id [String] The ID of the message to delete the reaction for
  # @param emoji [String] URL encoded emoji to delete, or name:id format for custom emojis
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.delete(url, headers)
    return response if response.status == 204

    @logger.error("Failed to delete own reaction with emoji ID #{emoji_id} in channel with ID #{channel_id} " \
                    "for message with ID #{message_id}. Response: #{response.body}")
    response
  end

  def delete_user_reaction(channel_id, message_id, emoji_id, user_id)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji_id}/#{user_id}"
  # Deletes a reaction with the specified emoji for a user in the specified message. Returns no content on success.
  # See https://discord.com/developers/docs/resources/message#delete-user-reaction
  # @param channel_id [String] The ID of the channel the message is located in
  # @param message_id [String] The ID of the message to delete the reaction for
  # @param emoji [String] URL encoded emoji to delete, or name:id format for custom emojis
  # @param user_id [String] The ID of the user to delete the reaction for
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.delete(url, headers)
    return response if response.status == 204

    @logger.error("Failed to delete user reaction with emoji ID #{emoji_id} in channel with ID #{channel_id} " \
                    "for message with ID #{message_id} by user with ID #{user_id}. Response: #{response.body}")
    response
  end

  def get_reactions(channel_id, message_id, emoji_id, type: nil, after: nil, limit: nil)
  # Gets a list of users that reacted with the specified emoji to the specified message. Returns an array of user
  # objects on success. See https://discord.com/developers/docs/resources/message#get-reactions
  # @param channel_id [String] The ID of the channel the message is located in
  # @param message_id [String] The ID of the message to get reactions for
  # @param emoji [String] URL encoded emoji to get reactions for, or name:id format for custom emojis
  # @param type [Integer, nil] Type of reaction to return.
  # @param after [String, nil] Get users after this user ID
  # @param limit [Integer, nil] Maximum number of users to return (1-100).
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
    query_string_hash = {}
    query_string_hash[:type] = type unless type.nil?
    query_string_hash[:after] = after unless after.nil?
    query_string_hash[:limit] = limit unless limit.nil?
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji_id}#{query_string}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get reactions for emoji with ID #{emoji_id} in channel with ID #{channel_id} " \
                    "for message with ID #{message_id}. Response: #{response.body}")
    response
  end

  # Deletes all reactions on a message. Returns no content on success.
  # See https://discord.com/developers/docs/resources/message#delete-all-reactions
  # @param channel_id [String] The ID of the channel the message is located in
  # @param message_id [String] The ID of the message to delete reactions for
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def delete_all_reactions(channel_id, message_id)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}/reactions"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.delete(url, headers)
    return response if response.status == 204

    @logger.error("Failed to delete all reactions in channel with ID #{channel_id} for message with ID #{message_id}" \
                    ". Response: #{response.body}")
  end

  def delete_all_reactions_for_emoji(channel_id, message_id, emoji_id)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}/reactions/#{emoji_id}"
  # Deletes all reactions with the specified emoji on a message. Returns no content on success.
  # See https://discord.com/developers/docs/resources/message#delete-all-reactions-for-emoji
  # @param channel_id [String] The ID of the channel the message is located in
  # @param message_id [String] The ID of the message to delete reactions for
  # @param emoji [String] URL encoded emoji to delete, or name:id format for custom emojis
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.delete(url, headers)
    return response if response.status == 204

    @logger.error("Failed to delete all reactions for emoji with ID #{emoji_id} in channel with ID #{channel_id} for " \
                    "message with ID #{message_id}. Response: #{response.body}")
  end

  # Edits a message. Returns the edited message object on success.
  # See https://discord.com/developers/docs/resources/message#edit-message
  #
  # If none of the optional parameters are provided (modifications), the function will not proceed and return nil.
  # Since the files parameter is WIP, providing only files will also cause the function to not proceed.
  # @param channel_id [String] The ID of the channel the message is located in
  # @param message_id [String] The ID of the message to edit
  # @param content [String, nil] Message contents (up to 2000 characters)
  # @param embeds [Array, nil] Up to 10 rich embeds (up to 6000 characters)
  # @param flags [Integer, nil] Message flags combined as an integer.
  # @param allowed_mentions [Hash, nil] Allowed mentions object
  # @param components [Array, nil] An array of Components to include with the message
  # @param files [nil] WORK IN PROGRESS
  # @param attachments [Array, nil] Attachments objects with filename and description. Practically useless due to
  #   uploading files not being implemented yet.
  # @return [Faraday::Response, nil] The response from the Discord API as a Faraday::Response object, or nil if no
  #  modifications were provided.
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
    return response if response.status == 200

    @logger.error("Failed to edit message with ID #{message_id} in channel with ID #{channel_id}. " \
                    "Response: #{response.body}")
    response
  end

  # Deletes a message. Returns no content on success.
  # See https://discord.com/developers/docs/resources/message#delete-message
  # @param channel_id [String] The ID of the channel the message is located in
  # @param message_id [String] The ID of the message to delete
  # @param audit_reason [String, nil] The reason for deleting the message. Shows up on the audit log.
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def delete_message(channel_id, message_id, audit_reason = nil)
    url = "#{@base_url}/channels/#{channel_id}/messages/#{message_id}"
    headers = { 'Authorization': @authorization_header }
    headers[:'X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.delete(url, headers)
    return response if response.status == 204

    @logger.error("Failed to delete message with ID #{message_id} in channel with ID #{channel_id}. " \
                    "Response: #{response.body}")
    response
  end

  # Bulk deletes messages. Returns no content on success.
  # See https://discord.com/developers/docs/resources/message#bulk-delete-messages
  # @param channel_id [String] The ID of the channel the messages are located in
  # @param messages [Array] An array of message IDs (as strings) to delete. (2-100 IDs)
  # @param audit_reason [String, nil] The reason for deleting the messages. Shows up on the audit log.
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def bulk_delete_messages(channel_id, messages, audit_reason = nil)
    output = { messages: messages }
    url = "#{@base_url}/channels/#{channel_id}/messages/bulk-delete"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    headers[:'X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.post(url, data, headers)
    return response if response.status == 204

    @logger.error("Failed to bulk delete messages in channel with ID #{channel_id}. Response: #{response.body}")
    response
  end

  # Gets pinned messages in a channel. See https://discord.com/developers/docs/resources/message#get-channel-pins for
  #   more info and response structure.
  # @param channel_id [String] The ID of the channel to get pinned messages from
  # @param before [String, nil] Get messages pinned before this ISO8601 timestamp
  # @param limit [Integer, nil] The maximum number of messages to return. (1-50, default 50)
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def get_channel_pins(channel_id, before: nil, limit: nil)
    query_string_hash = {}
    query_string_hash[:before] = before unless before.nil?
    query_string_hash[:limit] = limit unless limit.nil?
    query_string = DiscordApi.handle_query_strings(query_string_hash)
    url = "#{@base_url}/channels/#{channel_id}/messages/pins#{query_string}"
    headers = { 'Authorization': @authorization_header }
    response = DiscordApi.get(url, headers)
    return response if response.status == 200

    @logger.error("Failed to get pinned messages in channel with ID #{channel_id}. Response: #{response.body}")
    response
  end

  # Pins a message in a channel. Returns no content on success.
  # See https://discord.com/developers/docs/resources/message#pin-message
  # @param channel_id [String] The ID of the channel the message is located in
  # @param message_id [String] The ID of the message to pin
  # @param audit_reason [String, nil] The reason for pinning the message. Shows up in the audit log.
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def pin_message(channel_id, message_id, audit_reason = nil)
    url = "#{@base_url}/channels/#{channel_id}/messages/pins/#{message_id}"
    headers = { 'Authorization': @authorization_header }
    headers[:'X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.put(url, nil, headers)
    return response if response.status == 204

    @logger.error("Failed to pin message with ID #{message_id} in channel with ID #{channel_id}. " \
                    "Response: #{response.body}")
    response
  end

  # Unpins a message in a channel. Returns no content on success.
  # See https://discord.com/developers/docs/resources/message#unpin-message
  # @param channel_id [String] The ID of the channel the message is located in
  # @param message_id [String] The ID of the message to unpin
  # @param audit_reason [String, nil] The reason for unpinning the message. Shows up in the audit log.
  # @return [Faraday::Response] The response from the Discord API as a Faraday::Response object.
  def unpin_message(channel_id, message_id, audit_reason = nil)
    url = "#{@base_url}/channels/#{channel_id}/messages/pins/#{message_id}"
    headers = { 'Authorization': @authorization_header }
    headers[:'X-Audit-Log-Reason'] = audit_reason unless audit_reason.nil?
    response = DiscordApi.delete(url, headers)
    return response if response.status == 204

    @logger.error("Failed to unpin message with ID #{message_id} in channel with ID #{channel_id}. " \
                    "Response: #{response.body}")
    response
  end
end

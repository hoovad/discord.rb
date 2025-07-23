# frozen_string_literal: true

# DiscordApi
# The class that contains everything that interacts with the Discord API.
class DiscordApi
  def create_message(channel_id, content: nil, nonce: nil, tts: nil, embeds: nil, allowed_mentions: nil,
                     message_reference: nil, components: nil, sticker_ids: nil, files: nil, attachments: nil,
                     flags: nil, enforce_nonce: nil, poll: nil)
    if content.nil? && embeds.nil? && sticker_ids.nil? && components.nil? && files.nil? && poll.nil?
      @logger.warn('No content, embeds, sticker ids, components, files or poll provided. Skipping function.')
      return
    end
    output = {}
    output[:content] = content if content
    output[:nonce] = nonce if nonce
    output[:tts] = tts if tts
    output[:embeds] = embeds if embeds
    output[:allowed_mentions] = allowed_mentions if allowed_mentions
    output[:message_reference] = message_reference if message_reference
    output[:components] = components if components
    output[:sticker_ids] = sticker_ids if sticker_ids
    output[:files] = files if files
    output[:attachments] = attachments if attachments
    output[:flags] = flags if flags
    output[:enforce_nonce] = enforce_nonce if enforce_nonce
    output[:poll] = poll if poll
    url = "#{@base_url}/channels/#{channel_id}/messages"
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    response = DiscordApi.post(url, data, headers)
    return response unless response.status != 200

    @logger.error("Failed to create message in channel #{channel_id}. Response: #{response.body}")
    response
  end
end

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
end

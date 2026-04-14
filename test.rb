# frozen_string_literal: true

require_relative('lib/disrb')
require_relative('env')
VERBOSITY_LEVEL = nil if defined?(VERBOSITY_LEVEL) == false
discordapi = DiscordApi.new(TOKEN_TYPE, TOKEN, VERBOSITY_LEVEL)
discordapi.create_global_application_commands([%w[test test], %w[test2 test2], %w[file file]])
discordapi.connect_gateway(activities: { name: 'if i work', type: 3 }, presence_status: 'online',
                           presence_afk: false, presence_since: true) do |payload|
  if payload[:op].zero? && payload[:t] == 'INTERACTION_CREATE'
    discordapi.logger.info('Responding to payload')
    case payload[:d][:data][:name]
    when 'test'
      discordapi.respond_interaction(payload, { "type": 4, "data": { "content": 'Hi!' } })
    when 'test2'
      response = discordapi.respond_interaction(payload, { "type": 4, "data": { "content": 'Hello World!' } },
                                                with_response: true)
      if response.is_a?(Faraday::Response) && !response.body.to_s.empty?
        response = JSON.parse(response.body)
        discordapi.logger.debug("Interaction callback object: #{response}")
      end
    when 'file'
      data = { 'content': 'Hello World!',
               'attachments': [{ 'id' => 0, 'filename' => 'file.txt' }] }
      response = discordapi.respond_interaction(payload, { "type": 4, "data": data },
                                                files: [['file.txt', 'Hello World in a file!', 'text/plain']])
      if response.is_a?(Faraday::Response) && !response.body.to_s.empty?
        response = JSON.parse(response.body)
        discordapi.logger.debug("Interaction callback object: #{response}")
      end
    end
  elsif payload[:op].zero? && payload[:t] == 'MESSAGE_CREATE'
    if !payload[:d][:mentions].empty? && payload[:d][:mentions].each do |mention|
      mention[:id] == discordapi.application_id
    end && payload[:d][:author][:id] != discordapi.application_id
      discordapi.logger.info('Responding to message mention')
      discordapi.create_message(payload[:d][:channel_id], content: 'pong', message_reference: {
                                  type: 0,
                                  message_id: payload[:d][:id],
                                  channel_id: payload[:d][:channel_id],
                                  guild_id: payload[:d][:guild_id]
                                })
    end
  end
end

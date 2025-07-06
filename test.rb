# frozen_string_literal: true

require_relative('main')
require_relative('env')
VERBOSITY_LEVEL = nil if defined?(VERBOSITY_LEVEL) == false
discordapi = DiscordApi.new(TOKEN_TYPE, TOKEN, VERBOSITY_LEVEL)
discordapi.create_global_application_commands([['test'], ['test2']])
discordapi.connect_gateway(activities: { name: 'if i work', type: 3 }, presence_status: 'online',
                           presence_afk: false, presence_since: true) do |interaction|
  discordapi.logger.info('Responding to interaction')
  if interaction[:d][:data][:name] == 'test'
    discordapi.logger.debug(discordapi.respond_interaction(interaction, { "type": 4, "data": { "content": 'Hi!' } }))
  elsif interaction[:d][:data][:name] == 'test2'
    discordapi.logger.debug(discordapi.respond_interaction(interaction, { "type": 4, "data":
                                                           { "content": 'Hello World!' } }, with_response: true))
  end
end

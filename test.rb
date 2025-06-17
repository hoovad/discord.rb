# frozen_string_literal: true

require_relative('main')
require_relative('env')
APPLICATION_ID = nil if defined?(APPLICATION_ID) == false
discordapi = DiscordApi.new(TOKEN_TYPE, TOKEN, APPLICATION_ID)
discordapi.create_global_application_command('test')
discordapi.create_global_application_command('test2')
discordapi.connect_gateway do |interaction|
  Logger.info('Responding to interaction')
  if interaction[:d][:data][:name] == 'test'
    Logger.debug(discordapi.respond_interaction(interaction, { "type": 4, "data": { "content": 'Hi!' } }))
  elsif interaction[:d][:data][:name] == 'test2'
    Logger.debug(discordapi.respond_interaction(interaction, { "type": 4, "data": { "content": 'Hello World!' } }))
  end
end

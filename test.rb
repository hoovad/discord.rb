# frozen_string_literal: true
require_relative('main.rb')
require_relative('env.rb')
discordapi = DiscordApi.new(TOKEN_TYPE, TOKEN, APPLICATION_ID)
discordapi.create_global_application_command('test')
discordapi.create_global_application_command('test2')
discordapi.connect_gateway do |interaction|
  puts "Responding to interaction"
  if interaction[:d][:data][:name] == "test"
    p discordapi.respond_interaction(interaction, {"type": 4, "data": {"content": "Hi!"}})
  elsif interaction[:d][:data][:name] == "test2"
    p discordapi.respond_interaction(interaction,{"type": 4, "data": {"content": "Hello World!"}})
  end
end
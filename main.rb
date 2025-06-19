# frozen_string_literal: true

require 'net/http'
require 'json'
require 'async'
require 'async/http/endpoint'
require 'async/websocket/client'
require_relative 'guild'
require_relative 'logger'

# DiscordApi
# The class that contains everything that interacts with the Discord API.
class DiscordApi
  attr_accessor(:base_url, :authorization_header, :application_id, :interaction_created, :interaction)

  def initialize(authorization_token_type, authorization_token, application_id = nil)
    @api_version = '10'
    @base_url = "https://discord.com/api/v#{@api_version}"
    @authorization_header = "#{authorization_token_type} #{authorization_token}"
    if application_id.nil?
      url = URI("#{@base_url}/applications/@me")
      headers = { 'Authorization': @authorization_header }
      @application_id = JSON.parse(Net::HTTP.get(url, headers))['id']
    else
      @application_id = application_id
    end
    @interaction_created = false
    @interaction = {}
  end

  def self.handle_query_strings(query_string_hash)
    query_string_array = []
    query_string_hash.each do |key, value|
      if value.nil?
        next
      elsif query_string_array.empty?
        query_string_array << "?#{key}=#{value}"
      else
        query_string_array << "&#{key}=#{value}"
      end
    end
    query_string_array << '' if query_string_array.empty?
    query_string_array.join
  end

  def self.handle_snowflake(snowflake)
    snowflake = snowflake.to_s(2).rjust(64, '0')
    {
      discord_epoch_timestamp: snowflake[0..41],
      internal_worker_id: snowflake[42..46],
      internal_process_id: snowflake[47..51],
      gen_id_on_process: snowflake[52..64],
      unix_timestamp: snowflake[0..41].to_i(2) + 1_420_070_400_000,
      timestamp: Time.at((snowflake[0..41].to_i(2) + 1_420_070_400_000) / 1000).utc
    }
  end

  def create_guild_application_command(guild_id, name, name_localizations: nil, description: nil,
                                       description_localizations: nil, options: nil, default_member_permissions: nil,
                                       default_permission: true, type: 1, nsfw: false)
    output = {}
    output[:name] = name
    output[:name_localizations] = name_localizations unless name_localizations.nil?
    output[:description] = description unless description.nil?
    output[:description_localizations] = description_localizations unless description_localizations.nil?
    output[:options] = options unless options.nil?
    output[:default_permission] = default_permission
    output[:type] = type
    output[:nsfw] = nsfw
    output[:default_member_permissions] = default_member_permissions unless default_member_permissions.nil?
    url = URI("#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands")
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    Net::HTTP.post(url, data, headers)
  end

  def create_global_application_command(name, name_localizations = nil, description = nil,
                                        description_localizations = nil, options = nil,
                                        default_member_permissions = nil, default_permission: true,
                                        integration_types: nil, contexts: nil, type: 1, nsfw: false)
    output = {}
    output[:name] = name
    output[:name_localizations] = name_localizations unless name_localizations.nil?
    output[:description] = description unless description.nil?
    output[:description_localizations] = description_localizations unless description_localizations.nil?
    output[:options] = options unless options.nil?
    output[:default_permission] = default_permission
    output[:type] = type
    output[:nsfw] = nsfw
    output[:default_member_permissions] = default_member_permissions unless default_member_permissions.nil?
    output[:integration_types] = integration_types unless integration_types.nil?
    output[:contexts] = contexts unless contexts.nil?
    url = URI("#{@base_url}/applications/#{@application_id}/commands")
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    Net::HTTP.post(url, data, headers)
  end

  def edit_global_application_command(command_id, name = nil, name_localizations = nil, description = nil,
                                      description_localizations = nil, options = nil, default_member_permissions = nil,
                                      default_permission: true, integration_types: nil, contexts: nil, nsfw: nil)
    output = {}
    output[:name] = name
    output[:name_localizations] = name_localizations unless name_localizations.nil?
    output[:description] = description unless description.nil?
    output[:description_localizations] = description_localizations unless description_localizations.nil?
    output[:options] = options unless options.nil?
    output[:default_permission] = default_permission
    output[:nsfw] = nsfw
    output[:default_member_permissions] = default_member_permissions unless default_member_permissions.nil?
    output[:integration_types] = integration_types unless integration_types.nil?
    output[:contexts] = contexts unless contexts.nil?
    url = URI("#{@base_url}/applications/#{@application_id}/commands/#{command_id}")
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    Net::HTTP.patch(url, data, headers)
  end

  def edit_guild_application_command(guild_id, command_id, name = nil, name_localizations = nil, description = nil,
                                     description_localizations = nil, options = nil, default_member_permissions = nil,
                                     default_permission: true, nsfw: nil)
    output = {}
    output[:name] = name
    output[:name_localizations] = name_localizations unless name_localizations.nil?
    output[:description] = description unless description.nil?
    output[:description_localizations] = description_localizations unless description_localizations.nil?
    output[:options] = options unless options.nil?
    output[:default_permission] = default_permission
    output[:nsfw] = nsfw
    output[:default_member_permissions] = default_member_permissions unless default_member_permissions.nil?
    url = URI("#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands/#{command_id}")
    data = JSON.generate(output)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    Net::HTTP.patch(url, data, headers)
  end

  def delete_global_application_command(command_id)
    url = URI("#{@base_url}/applications/#{@application_id}/commands/#{command_id}")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.delete(url, headers)
  end

  def delete_guild_application_command(guild_id, command_id)
    url = URI("#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands/#{command_id}")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.delete(url, headers)
  end

  def get_guild_application_commands(guild_id, with_localizations: false)
    url = URI("#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands?with_localizations=" \
          "#{with_localizations}")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.get(url, headers)
  end

  def get_global_application_commands(with_localizations: false)
    url = URI("#{@base_url}/applications/#{@application_id}/commands?with_localizations=#{with_localizations}")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.get(url, headers)
  end

  def get_global_application_command(command_id)
    url = URI("#{@base_url}/applications/#{@application_id}/commands/#{command_id}")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.get(url, headers)
  end

  def get_guild_application_command(guild_id, command_id)
    url = URI("#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands/#{command_id}")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.get(url, headers)
  end

  def bulk_overwrite_global_application_commands(commands)
    url = URI("#{@base_url}/applications/#{@application_id}/commands")
    data = JSON.generate(commands)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    Net::HTTP.put(url, data, headers)
  end

  def bulk_overwrite_guild_application_commands(guild_id, commands)
    url = URI("#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands")
    data = JSON.generate(commands)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    Net::HTTP.put(url, data, headers)
  end

  def get_guild_application_command_permissions(guild_id)
    url = URI("#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands/permissions")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.get(url, headers)
  end

  def get_application_command_permissions(guild_id, command_id)
    url = URI("#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands/#{command_id}/permissions")
    headers = { 'Authorization': @authorization_header }
    Net::HTTP.get(url, headers)
  end

  def edit_application_command_permissions(guild_id, command_id, permissions)
    url = URI("#{@base_url}/applications/#{@application_id}/guilds/#{guild_id}/commands/#{command_id}/permissions")
    data = JSON.generate(permissions)
    headers = { 'Authorization': @authorization_header, 'Content-Type': 'application/json' }
    Net::HTTP.put(url, data, headers)
  end

  def connect_gateway(&block)
    Async do |_task|
      url = "#{JSON.parse(Net::HTTP.get(URI("#{@base_url}/gateway")))['url']}/?v=#{@api_version}&encoding=json"
      endpoint = Async::HTTP::Endpoint.parse(url, alpn_protocols: Async::HTTP::Protocol::HTTP11.names)

      Async::WebSocket::Client.connect(endpoint) do |connection|
        connection.write JSON.generate({ op: 1, d: nil })
        connection.flush

        connection.write JSON.generate({ op: 2,
                                         d: { token: @authorization_header, intents: 513,
                                              properties: { os: 'linux', browser: 'discord.rb',
                                                            device: 'discord.rb' } } })
        connection.flush

        loop do
          message = connection.read
          message = JSON.parse(message, symbolize_names: true)
          Logger.debug(message)

          case message
          in { op: 10 }
            Logger.info('Received Hello')
            @heartbeat_interval = message[:d][:heartbeat_interval]
          in { op:  1 }
            Logger.info('Received Heartbeat Request')
            connection.write JSON.generate({ op: 1, d: nil })
            connection.flush
          in { op: 11 }
            Logger.info('Received Heartbeat ACK')
          in { op: 0, t: 'INTERACTION_CREATE' }
            Logger.info('An interaction was created')
            block.call(message)
          in { op: 0 }
            Logger.info('An event was dispatched')
          else
            Logger.error('Unimplemented event type')
          end
        end
      end
    end
  end

  def respond_interaction(interaction, response, with_response: false)
    url = URI("#{@base_url}/interactions/#{interaction[:d][:id]}/#{interaction[:d][:token]}/callback?with_response=" \
    "#{with_response}")
    data = JSON.generate(response)
    headers = { 'content-type': 'application/json' }
    Net::HTTP.post(url, data, headers)
  end

  def self.calculate_permissions_integer(permissions)
    bitwise_permission_flags = {
      create_instant_invite: 0x0000000000000001,
      kick_members: 0x0000000000000002,
      ban_members: 0x0000000000000004,
      administrator: 0x0000000000000008,
      manage_channels: 0x0000000000000010,
      manage_guild: 0x0000000000000020,
      add_reactions: 0x0000000000000040,
      view_audit_log: 0x0000000000000080,
      priority_speaker: 0x0000000000000100,
      stream: 0x0000000000000200,
      view_channel: 0x0000000000000400,
      send_messages: 0x0000000000000800,
      send_tts_messages: 0x0000000000001000,
      manage_messages: 0x0000000000002000,
      embed_links: 0x0000000000004000,
      attach_files: 0x0000000000008000,
      read_message_history: 0x0000000000010000,
      mention_everyone: 0x0000000000020000,
      use_external_emojis: 0x0000000000040000,
      view_guild_insights: 0x0000000000080000,
      connect: 0x0000000000100000,
      speak: 0x0000000000200000,
      mute_members: 0x0000000000400000,
      deafen_members: 0x0000000000800000,
      move_members: 0x0000000001000000,
      use_vad: 0x0000000002000000,
      change_nickname: 0x0000000004000000,
      manage_nicknames: 0x0000000008000000,
      manage_roles: 0x0000000010000000,
      manage_webhooks: 0x0000000020000000,
      manage_guild_expressions: 0x0000000040000000,
      use_application_commands: 0x0000000080000000,
      request_to_speak: 0x0000000100000000,
      manage_events: 0x0000000200000000,
      manage_threads: 0x0000000400000000,
      create_public_threads: 0x0000000800000000,
      create_private_threads: 0x0000001000000000,
      use_external_stickers: 0x0000002000000000,
      send_messages_in_threads: 0x0000004000000000,
      use_embedded_activities: 0x0000008000000000,
      moderate_members: 0x0000010000000000,
      view_creator_monetization_analytics: 0x0000020000000000,
      use_soundboard: 0x0000040000000000,
      create_guild_expressions: 0x0000080000000000,
      create_events: 0x0000100000000000,
      use_external_sounds: 0x0000200000000000,
      send_voice_messages: 0x0000400000000000,
      send_polls: 0x0002000000000000,
      use_external_apps: 0x0004000000000000
    }
    permissions = permissions.map do |permission|
      bitwise_permission_flags[permission.downcase.to_sym]
    end
    permissions.reduce(0) { |acc, n| acc | n }
  end
end

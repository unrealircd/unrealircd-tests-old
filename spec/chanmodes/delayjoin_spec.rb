require 'spec_helper'

describe 'Channel Mode D/d (delayjoin)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    @test_channel = '#test'
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1a = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1a')
    @cbot1b = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1b')
  end

  it 'should not show users joining a mode +d channel' do
    @swarm.perform do
      @obot.send("JOIN #{@test_channel}")
      sleep(0.5)
      channel = @obot.channel_with_name(@test_channel)
      channel.mode('+D')
      sleep(0.5)
      @cbot1a.send("JOIN #{@test_channel}")
      @cbot1b.send("JOIN #{@test_channel}")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1a.received_pattern(/cbot1b/)).not_to eq(true)
    expect(@cbot1b.received_pattern(/cbot1a/)).not_to eq(true)
  end

  it 'should show operators joining a mode +d channel'
  it 'should show operators when promoted after joining a mode +d channel'
  it 'should show a user after they speak in a mode +d channel'
  it 'should keep mode +D after -d until all hidden users leave or are shown'
end

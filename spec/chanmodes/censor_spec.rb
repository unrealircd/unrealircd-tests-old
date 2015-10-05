require 'spec_helper'

describe 'Channel Mode G (censor)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    @test_channel = '#censor'
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should censor bad words' do
    @swarm.perform do
      @obot.send("JOIN #{@test_channel}")
      sleep(1)
      @cbot1.send("JOIN #{@test_channel}")
      sleep(1)
      channel = @obot.channel_with_name(@test_channel)
      channel.mode('+G')
      sleep(2)
      @cbot1.send("PRIVMSG #{@test_channel} :aa fucked bb")
      sleep(2)
    end
    @swarm.execute
    expect(@obot.received_pattern(/fuck/)).not_to eq(true)
    expect(@obot.received_pattern(/aa <censored> bb/)).to eq(true)
  end

  it 'should not censor good words' do
    @swarm.perform do
      @obot.send("JOIN #{@test_channel}")
      sleep(1)
      @cbot1.send("JOIN #{@test_channel}")
      sleep(1)
      channel = @obot.channel_with_name(@test_channel)
      channel.mode('+G')
      sleep(2)
      @cbot1.send("PRIVMSG #{@test_channel} :sunshine")
      sleep(2)
    end
    @swarm.execute
    expect(@obot.received_pattern(/sunshine/)).to eq(true)
  end

end

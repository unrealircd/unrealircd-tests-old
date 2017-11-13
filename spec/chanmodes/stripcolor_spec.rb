require 'spec_helper'

describe 'Channel Mode S (stripcolor)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should disallow color codes' do
    @swarm.perform do
      @obot.send("JOIN #color")
      @obot.send("MODE #color +S")
      sleep(0.5)
      @cbot1.send("JOIN #color")
      @cbot1.send("PRIVMSG #color :\0034this is red\003")
      sleep(0.5)
    end
    @swarm.execute
    expect(@obot.received_pattern(/\0034this is red/)).not_to eq(true)
    expect(@obot.received_pattern(/this is red/)).to eq(true)
  end

  it 'should disallow reverse control codes' do
    @swarm.perform do
      @obot.send("JOIN #color")
      @obot.send("MODE #color +S")
      sleep(0.5)
      @cbot1.send("JOIN #color")
      @cbot1.send("PRIVMSG #color :\026this is reverse\026")
      sleep(0.5)
    end
    @swarm.execute
    expect(@obot.received_pattern(/\026this is reverse/)).not_to eq(true)
    expect(@obot.received_pattern(/this is reverse/)).to eq(true)
  end
end

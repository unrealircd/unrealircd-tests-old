require 'spec_helper'

describe 'Channel Mode V (noinvite)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should disallow INVITE if +V' do
    @swarm.perform do
      @obot.send("JOIN #invite")
      @obot.send("MODE #invite +Vi")
      sleep(3)
      @obot.send("INVITE cbot1 #invite")
      sleep(2)
      @cbot1.send("JOIN #invite")
      sleep(2)
    end
    @swarm.execute
    # We expect the invite to be blocked
    expect(@obot.received_pattern(/Cannot invite/)).to eq(true)
    # And we DO NOT want to see a JOIN ;)
    expect(@cbot1.received_pattern(/:cbot1.*JOIN/)).not_to eq(true)
    expect(@cbot1.received_pattern(/Cannot join channel/)).to eq(true)
  end

end

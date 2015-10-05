require 'spec_helper'

describe 'Channel Mode Q (nokick)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should disallow KICK' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +Q")
      @cbot1.send("JOIN #test")
      sleep(4)
      @obot.send("KICK #test cbot1")
      sleep(2)
    end
    @swarm.execute
    expect(@obot.received_pattern(/972.*KICK/)).to eq(true)
    expect(@cbot1.received_pattern(/:obot.*KICK/)).not_to eq(true)
  end
end

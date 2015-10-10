require 'spec_helper'

describe 'Channel Mode R (regonly)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should prevent users from joining who are not identified to services' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +R")
      sleep(3)
      @cbot1.send("JOIN #test")
      sleep(3)
    end
    @swarm.execute
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).not_to eq(true)
    expect(@cbot1.received_pattern(/477.*You need a registered nick to join/)).to eq(true)
  end

  it 'should not prevent users from joining who are identified to services'

end

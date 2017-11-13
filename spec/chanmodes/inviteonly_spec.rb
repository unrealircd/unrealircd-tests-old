require 'spec_helper'

describe 'Channel Mode i (invite only)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should not allow joins with +i' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +i")
      sleep(0.5)
      @cbot1.send("JOIN #test")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/473.*Cannot join/)).to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).not_to eq(true)
  end

  it 'should allow joins without -i' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test -i")
      sleep(0.5)
      @cbot1.send("JOIN #test")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/473.*Cannot join/)).not_to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).to eq(true)
  end
end

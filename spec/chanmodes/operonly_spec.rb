require 'spec_helper'

describe 'Channel Mode O (operonly)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should prevent non-ircops from joining' do
    @swarm.perform do
      @obot.send("OPER netadmin test")
      @obot.send("JOIN #test")
      @obot.send("MODE #test +O")
      sleep(0.5)
      @cbot1.send("JOIN #test")
      sleep(0.5)
    end
    @swarm.execute
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).not_to eq(true)
    expect(@cbot1.received_pattern(/520.*Cannot join channel/)).to eq(true)
  end

  it 'should not prevent ircops from joining' do
    @swarm.perform do
      @obot.send("OPER netadmin test")
      @cbot1.send("OPER netadmin test")
      @obot.send("JOIN #test")
      @obot.send("MODE #test +O")
      sleep(0.5)
      @cbot1.send("JOIN #test")
      sleep(0.5)
    end
    @swarm.execute
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).to eq(true)
    expect(@cbot1.received_pattern(/520.*Cannot join channel/)).not_to eq(true)
  end

end

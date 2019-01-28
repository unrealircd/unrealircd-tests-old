require 'spec_helper'

describe 'Channel Mode L (link)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should send users to linked channel (+L) if limit is reached (+l)' do
    @swarm.perform do
      @obot.send("JOIN #one")
      @obot.send("OPER netadmin test")
      @obot.send("MODE #one +lL 1 #two")
      sleep(0.5)
      @cbot1.send("JOIN #one")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/:cbot1.*JOIN.*\#one/)).not_to eq(true)
    expect(@cbot1.received_pattern(/:cbot1.*JOIN.*\#two/)).to eq(true)
  end

  it 'should not send users to linked channel (+L) if limit is not reached (+l)' do
    @swarm.perform do
      @obot.send("JOIN #one")
      @obot.send("OPER netadmin test")
      @obot.send("MODE #one +lL 99 #two")
      sleep(0.5)
      @cbot1.send("JOIN #one")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/:cbot1.*JOIN.*\#one/)).to eq(true)
    expect(@cbot1.received_pattern(/:cbot1.*JOIN.*\#two/)).not_to eq(true)
  end

end

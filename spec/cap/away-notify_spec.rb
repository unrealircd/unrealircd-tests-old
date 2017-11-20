require 'spec_helper'

describe 'CAP away-notify' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot', user: 'xxidentyy')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should show AWAY changes if enabled' do
    @swarm.perform do
      sleep(0.5)
      @cbot1.send("CAP REQ away-notify")
      @obot.send("JOIN #test")
      @cbot1.send("JOIN #test")
      sleep(0.5)
      @obot.send("AWAY :going away")
      @obot.send("AWAY")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/CAP.*ACK.*away-notify/)).to eq(true)
    expect(@cbot1.received_pattern(/:obot.* AWAY :going away/)).to eq(true)
    expect(@cbot1.received_pattern(/:obot.* AWAY$/)).to eq(true)
  end

  it 'should not show AWAY changes if not enabled' do
    @swarm.perform do
      sleep(0.5)
      @obot.send("JOIN #test")
      sleep(0.5)
      @cbot1.send("CAP REQ -away-notify")
      @cbot1.send("JOIN #test")
      sleep(0.5)
      @obot.send("AWAY :going away")
      sleep(0.5)
      @obot.send("AWAY")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/:obot.* AWAY/)).not_to eq(true)
  end

end

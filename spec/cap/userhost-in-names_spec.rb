require 'spec_helper'

describe 'CAP userhost-in-names' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot', user: 'xxidentyy')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should show user@host in NAMES' do
    @swarm.perform do
      @obot.send("JOIN #test")
      sleep(0.1)
      @cbot1.send("CAP REQ userhost-in-names")
      @cbot1.send("JOIN #test")
      sleep(0.2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/CAP.*ACK.*userhost-in-names/)).to eq(true)
    expect(@cbot1.received_pattern(/353.*obot.*xxidentyy/)).to eq(true)
  end

  it 'should not show user@host in NAMES if not enabled' do
    @swarm.perform do
      @obot.send("JOIN #test")
      sleep(0.1)
      @cbot1.send("CAP REQ -userhost-in-names")
      @cbot1.send("JOIN #test")
      sleep(0.2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/353.*obot.*xxidentyy/)).not_to eq(true)
  end
end

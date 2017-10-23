require 'spec_helper'

describe 'CAP invite-notify' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
    @cbot2 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot2')
  end

  it 'should show /invites if enabled' do
    @swarm.perform do
      @obot.send("JOIN #test")
      sleep(1)
      @cbot1.send("CAP REQ invite-notify")
      @cbot1.send("JOIN #test")
      sleep(2)
      @obot.send("MODE #test +o cbot1")
      sleep(2)
      @obot.send("INVITE cbot2 #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/CAP.*ACK.*invite-notify/)).to eq(true)
    expect(@cbot1.received_pattern(/:obot.* INVITE cbot2/)).to eq(true)
  end

  it 'should not show /invites if not enabled' do
    @swarm.perform do
      @obot.send("JOIN #test")
      sleep(1)
      @cbot1.send("CAP REQ -invite-notify")
      @cbot1.send("JOIN #test")
      sleep(2)
      @obot.send("MODE #test +o cbot1")
      sleep(2)
      @obot.send("INVITE cbot2 #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/:obot.* INVITE cbot2/)).not_to eq(true)
  end

end

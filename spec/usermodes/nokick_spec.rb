require 'spec_helper'

describe 'User Mode q (nokick)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should disallow KICK' do
    @swarm.perform do
      @obot.send("OPER netadmin test")
      @obot.send("JOIN #test")
      @obot.send("MODE obot +q")
      sleep(0.5)
      @cbot1.send("JOIN #test")
      sleep(0.5)
      @obot.send("MODE #test +o cbot1")
      sleep(0.5)
      @cbot1.send("KICK #test obot")
      sleep(0.5)
    end
    @swarm.execute
    expect(@obot.received_pattern(/cbot1 tried to kick you/)).to eq(true)
    expect(@cbot1.received_pattern(/user is unkickable/)).to eq(true)
    expect(@obot.received_pattern(/:cbot1.*KICK/)).not_to eq(true)
  end
end

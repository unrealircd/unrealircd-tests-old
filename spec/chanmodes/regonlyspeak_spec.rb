require 'spec_helper'

describe 'Channel Mode M (regonlyspeak)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should disallow messages from users who are not identified to services' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +M")
      sleep(1)
      @cbot1.send("JOIN #test")
      sleep(1)
      @cbot1.send("PRIVMSG #test :this should be rejected")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/404.*You must have a registered nick/)).to eq(true)
    expect(@obot.received_pattern(/this should be rejected/)).not_to eq(true)
  end

  it 'should allow messages from users who are identified to services'

end

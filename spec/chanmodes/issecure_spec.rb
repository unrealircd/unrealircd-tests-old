require 'spec_helper'

describe 'Channel Mode z/Z (secureonly/issecure)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    @test_channel = '#secure'
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.ssl_port, ssl: true, nick: 'obot')
    @secbot = @swarm.fly(server: server.host, port: server.ssl_port, ssl: true, nick: 'secbot')
    @insecbot = @swarm.fly(server: server.host, port: server.port, nick: 'insecbot')
  end

  it 'should only allow SSL users when +z' do
    @swarm.perform do
      @obot.send("JOIN #secure")
      @obot.send("MODE #secure +z")
      sleep(2)
      @secbot.send("JOIN #secure")
      @insecbot.send("JOIN #secure")
    end
    @swarm.execute

    expect(@secbot.received_pattern(/NAMES list/)).to eq(true)
    expect(@secbot.received_pattern(/Cannot join channel/)).not_to eq(true)

    expect(@insecbot.received_pattern(/NAMES list/)).not_to eq(true)
    expect(@insecbot.received_pattern(/Cannot join channel/)).to eq(true)
  end

 it 'should set +Z when all users are secure'
 
 it 'should be -Z when insecure users are present'

end

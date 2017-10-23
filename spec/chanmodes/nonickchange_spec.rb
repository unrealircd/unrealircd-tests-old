require 'spec_helper'

describe 'Channel Mode N (nonickchange)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should disallow nick changes' do
    @swarm.perform do
      @obot.send("JOIN #nickchange")
      @obot.send("MODE #nickchange +N")
      sleep(0.2)
      @cbot1.send("JOIN #nickchange")
      @cbot1.send("NICK nonickchg")
      sleep(0.2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/Can not change nickname/)).to eq(true)
    expect(@obot.received_pattern(/nonickchg/)).not_to eq(true)
  end
end

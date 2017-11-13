require 'spec_helper'

describe 'Channel Mode K (noknock)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should disallow KNOCK if +K' do
    @swarm.perform do
      @obot.send("JOIN #knock")
      @obot.send("MODE #knock +iK")
      sleep(0.5)
      @cbot1.send("KNOCK #knock")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/No knocks are allowed/)).to eq(true)
    expect(@obot.received_pattern(/\[Knock\] by /)).not_to eq(true)
  end

  it 'should allow KNOCK if -K' do
    @swarm.perform do
      @obot.send("JOIN #knock")
      @obot.send("MODE #knock +i-K")
      sleep(0.5)
      @cbot1.send("KNOCK #knock")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/Knocked on #knock/)).to eq(true)
    expect(@obot.received_pattern(/\[Knock\] by /)).to eq(true)
  end
end

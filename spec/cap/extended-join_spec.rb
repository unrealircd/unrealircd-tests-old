require 'spec_helper'

describe 'CAP extended-join' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
    @cbot2 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot2', name: 'This is my realname')
  end

  it 'should show gecos in extended-join' do
    @swarm.perform do
      @cbot1.send("CAP REQ extended-join")
      @cbot1.send("JOIN #test")
      sleep(0.5)
      @cbot2.send("JOIN #test")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/:cbot2.* JOIN #test \* :This is my realname/)).to eq(true)
  end

  it 'should not show gecos without extended-join' do
    @swarm.perform do
      @cbot1.send("JOIN #test")
      sleep(0.5)
      @cbot2.send("JOIN #test")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/:cbot2.*This is my realname/)).not_to eq(true)
    expect(@cbot1.received_pattern(/:cbot2.* JOIN.*#test/)).to eq(true)
  end
end

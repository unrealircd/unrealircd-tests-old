require 'spec_helper'

describe 'CAP extended-join' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @cbot1a = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1a')
    @cbot1b = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1b', name: 'This is my realname')
  end

  it 'should show gecos in extended-join' do
    @swarm.perform do
      @cbot1a.send("CAP REQ extended-join")
      @cbot1a.send("JOIN #test")
      sleep(0.5)
      @cbot1b.send("JOIN #test")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1a.received_pattern(/:cbot1b.* JOIN \#test \* :This is my realname/)).to eq(true)
  end

  it 'should not show gecos without extended-join' do
    @swarm.perform do
      @cbot1a.send("JOIN #test")
      sleep(0.5)
      @cbot1b.send("JOIN #test")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1a.received_pattern(/:cbot1b.*This is my realname/)).not_to eq(true)
    expect(@cbot1a.received_pattern(/:cbot1b.* JOIN.*\#test/)).to eq(true)
  end
end

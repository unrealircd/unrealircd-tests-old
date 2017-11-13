require 'spec_helper'

describe 'Channel Mode T (nonotice)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should disallow NOTICE' do
    @swarm.perform do
      @obot.send("JOIN #notice")
      @obot.send("MODE #notice +T")
      sleep(0.5)
      @cbot1.send("JOIN #notice")
      @cbot1.send("NOTICE #notice :this is a test notice")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/NOTICEs are not permitted in this channel/)).to eq(true)
    expect(@obot.received_pattern(/this is a test notice/)).not_to eq(true)
  end
end

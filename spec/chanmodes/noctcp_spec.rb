require 'spec_helper'

describe 'Channel Mode C (noctcp)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should disallow CTCP' do
    @swarm.perform do
      @obot.send("JOIN #ctcp")
      @obot.send("MODE #ctcp +C")
      sleep(2)
      @cbot1.send("JOIN #ctcp")
      @cbot1.send("PRIVMSG #ctcp :\001CTCPTEST\001")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/CTCPs are not permitted in this channel/)).to eq(true)
    expect(@obot.received_pattern(/CTCPTEST/)).not_to eq(true)
  end
end

require 'spec_helper'

describe 'User Mode T (noctcp)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    servera = IRC_CONFIG.servers['primary']
    serverb = IRC_CONFIG.servers['secondary']
    @cbot1 = @swarm.fly(server: servera.host, port: servera.port, nick: 'cbot1')
    @cbot2 = @swarm.fly(server: serverb.host, port: serverb.port, nick: 'cbot2')
  end

  it 'should error and block CTCP' do
    @swarm.perform do
      @cbot2.send("MODE cbot2 +T")
      sleep(0.2)
      @cbot1.send("PRIVMSG cbot2 :\001CTCPTEST\001")
      sleep(0.2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/does not accept CTCPs/)).to eq(true)
    expect(@cbot2.received_pattern(/CTCPTEST/)).not_to eq(true)
  end

end

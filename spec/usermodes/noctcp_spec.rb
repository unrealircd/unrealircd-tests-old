require 'spec_helper'

describe 'User Mode T (noctcp)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    servera = IRC_CONFIG.servers['primary']
    serverb = IRC_CONFIG.servers['secondary']
    @cbot1 = @swarm.fly(server: servera.host, port: servera.port, nick: 'cbot1')
    @cbot2 = @swarm.fly(server: serverb.host, port: serverb.port, nick: 'cbot2')
  end

  it 'should error and block CTCP if target has +T' do
    @swarm.perform do
      @cbot2.send("MODE cbot2 +T")
      sleep(1)
      @cbot1.send("PRIVMSG cbot2 :\001CTCPTEST\001")
      sleep(1)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/does not accept CTCPs/)).to eq(true)
    expect(@cbot2.received_pattern(/CTCPTEST/)).not_to eq(true)
  end

  it 'should allow CTCP if from IRCOp and target has +T' do
    @swarm.perform do
      @cbot1.send("OPER netadmin test")
      @cbot2.send("MODE cbot2 +T")
      sleep(1)
      @cbot1.send("PRIVMSG cbot2 :\001CTCPTEST\001")
      sleep(1)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/does not accept CTCPs/)).not_to eq(true)
    expect(@cbot2.received_pattern(/CTCPTEST/)).to eq(true)
  end

  it 'should allow CTCP if from IRCOp and sender has +T' do
    @swarm.perform do
      @cbot1.send("OPER netadmin test")
      @cbot1.send("MODE cbot1 +T")
      sleep(1)
      @cbot1.send("PRIVMSG cbot2 :\001CTCPTEST\001")
      sleep(1)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/CTCP request.*blocked/)).not_to eq(true)
    expect(@cbot2.received_pattern(/CTCPTEST/)).to eq(true)
  end

end

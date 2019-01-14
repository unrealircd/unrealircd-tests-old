require 'spec_helper'

# We combine the SQUIT and CONNECT tests as to not leave the server
# in a bad state (unlinked).

# Remark: in contrary to many other tests, the oper bot is on the secondary
# server in this tests and the other one on the primary. This is because in
# the ircd config we only allow the secondary to connect to the primary and
# not the other way around (we could change the config to allow this, but
# it is meant to be this way so we can test link blocks without a
# link::outgoing section).

describe 'SQUIT and CONNECT commands' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    servera = IRC_CONFIG.servers['primary']
    serverb = IRC_CONFIG.servers['secondary']
    @cbot1 = @swarm.fly(server: servera.host, port: servera.port, nick: 'cbot1')
    @obot2 = @swarm.fly(server: serverb.host, port: serverb.port, nick: 'obot2')
  end

  it 'should disallow SQUIT to normal users' do
    @swarm.perform do
      @obot2.send("SQUIT irc1.test.net")
    end
    @swarm.execute
    # We expect the command to error
    expect(@obot2.received_pattern(/ 481 /)).to eq(true)
  end

  it 'should disallow CONNECT to normal users' do
    @swarm.perform do
      @obot2.send("CONNECT irc1.test.net")
    end
    @swarm.execute
    # We expect the command to error
    expect(@obot2.received_pattern(/ 481 /)).to eq(true)
  end

  it 'should allow SQUIT and CONNECT to opers' do
    @swarm.perform do
      @obot2.send("OPER netadmin test")
      sleep(1)
      @obot2.send("PRIVMSG cbot1 :before squit")
      @obot2.send("SQUIT irc1.test.net")
      @obot2.send("PRIVMSG cbot1 :after squit")
      sleep(0.5)
      @obot2.send("CONNECT irc1.test.net")
      sleep(1.5)
      @obot2.send("PRIVMSG cbot1 :after reconnect")
      sleep(1)
    end
    @swarm.execute
    # Errors are not expected
    expect(@obot2.received_pattern(/ 481 /)).not_to eq(true)
    # We should receive the 'before squit', this is to ensure the test goes correctly.
    expect(@cbot1.received_pattern(/.*PRIVMSG.*before squit/)).to eq(true)
    # We should NOT receive the 'after squit', since servers should not be linked
    expect(@cbot1.received_pattern(/.*PRIVMSG.*after squit/)).not_to eq(true)
    # ..we should get an error instead about no such nick:
    expect(@obot2.received_pattern(/:.*401 obot2 cbot1/)).to eq(true)
    # We should receive the 'after reconnect', since now we are linked again
    expect(@cbot1.received_pattern(/.*PRIVMSG.*after reconnect/)).to eq(true)
  end

end

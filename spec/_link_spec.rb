require 'spec_helper'

# This links the servers, needed for the other tests.
describe 'CONNECT commands' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    servera = IRC_CONFIG.servers['primary']
    serverb = IRC_CONFIG.servers['secondary']
    @obot1 = @swarm.fly(server: servera.host, port: servera.port, nick: 'obot1')
    @obot2 = @swarm.fly(server: serverb.host, port: serverb.port, nick: 'obot2')
  end

  it 'should link the servers' do
    @swarm.perform do
      @obot1.send("OPER netadmin test")
      @obot2.send("OPER netadmin test")
      @obot1.send("CONNECT hub.test.net")
      @obot2.send("CONNECT hub.test.net")
      sleep(2)
      @obot2.send("PRIVMSG obot1 :seems we are linked")
      sleep(3)
    end
    @swarm.execute
    # Errors are not expected
    expect(@obot2.received_pattern(/ 481 /)).not_to eq(true)
    # We should receive the 'after reconnect', since now we are linked again
    expect(@obot1.received_pattern(/.*PRIVMSG.*seems we are linked/)).to eq(true)
  end

end

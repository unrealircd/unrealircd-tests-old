require 'spec_helper'

describe 'CHGHOST command' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    servera = IRC_CONFIG.servers['primary']
    serverb = IRC_CONFIG.servers['secondary']
    @obot = @swarm.fly(server: servera.host, port: servera.port, nick: 'obot')
    @cbot2 = @swarm.fly(server: serverb.host, port: serverb.port, nick: 'cbot2')
  end

  it 'should disallow CHGHOST to normal users' do
    @swarm.perform do
      @obot.send("CHGHOST obot some.nice.new.vhost")
      @obot.send("WHOIS obot")
    end
    @swarm.execute
    # We expect the command to error
    expect(@obot.received_pattern(/ 481 /)).to eq(true)
    expect(@obot.received_pattern(/ some.nice.new.vhost :is now your displayed host/)).not_to eq(true)
    expect(@obot.received_pattern(/ 311.* some.nice.new.vhost/)).not_to eq(true)
  end

  it 'should disallow CHGHOST to opers with insufficient privileges' do
    @swarm.perform do
      @obot.send("OPER locop test")
      @obot.send("CHGHOST obot some.nice.new.vhost")
      @obot.send("WHOIS obot")
    end
    @swarm.execute
    # We expect the command to error
    expect(@obot.received_pattern(/ 481 /)).to eq(true)
    expect(@obot.received_pattern(/ some.nice.new.vhost :is now your displayed host/)).not_to eq(true)
    expect(@obot.received_pattern(/ 311.* some.nice.new.vhost/)).not_to eq(true)
  end

  # We run this one one a remote user, to get a better test
  it 'should allow CHGHOST to opers' do
    @swarm.perform do
      @obot.send("OPER netadmin test")
      sleep(1)
      @obot.send("CHGHOST cbot2 some.nice.new.vhost")
      sleep(1)
      @cbot2.send("WHOIS cbot2")
      @obot.send("WHOIS cbot2")
    end
    @swarm.execute
    # Error is not expected
    expect(@obot.received_pattern(/ 481 /)).not_to eq(true)
    # User should get a message about the new host
    expect(@cbot2.received_pattern(/ some.nice.new.vhost :is now your displayed host/)).to eq(true)
    # WHOIS from both servers should show the user with the new vhost
    expect(@obot.received_pattern(/ 311.* some.nice.new.vhost/)).to eq(true)
    expect(@cbot2.received_pattern(/ 311.* some.nice.new.vhost/)).to eq(true)
  end

end

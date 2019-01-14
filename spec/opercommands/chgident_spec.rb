require 'spec_helper'

describe 'CHGIDENT command' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    servera = IRC_CONFIG.servers['primary']
    serverb = IRC_CONFIG.servers['secondary']
    @obot = @swarm.fly(server: servera.host, port: servera.port, nick: 'obot')
    @cbot2 = @swarm.fly(server: serverb.host, port: serverb.port, nick: 'cbot2')
  end

  it 'should disallow CHGIDENT to normal users' do
    @swarm.perform do
      @obot.send("CHGIDENT obot changedid")
      @obot.send("WHOIS obot")
      sleep(0.5)
    end
    @swarm.execute
    # We expect the command to error
    expect(@obot.received_pattern(/ 481 /)).to eq(true)
    expect(@obot.received_pattern(/ 311.* changedid/)).not_to eq(true)
  end

  it 'should disallow CHGIDENT to opers with insufficient privileges' do
    @swarm.perform do
      @obot.send("OPER locop test")
      @obot.send("CHGIDENT obot changedid")
      @obot.send("WHOIS obot")
    end
    @swarm.execute
    # We expect the command to error
    expect(@obot.received_pattern(/ 481 /)).to eq(true)
    expect(@obot.received_pattern(/ 311.* changedid/)).not_to eq(true)
  end

  # We run this one one a remote user, to get a better test
  it 'should allow CHGIDENT to opers' do
    @swarm.perform do
      @obot.send("OPER netadmin test")
      sleep(0.5)
      @obot.send("CHGIDENT cbot2 changedid")
      sleep(0.5)
      @cbot2.send("WHOIS cbot2")
      @obot.send("WHOIS cbot2")
    end
    @swarm.execute
    # Error is not expected
    expect(@obot.received_pattern(/ 481 /)).not_to eq(true)
    # WHOIS from both servers should show the user with the new vhost
    expect(@obot.received_pattern(/ 311.* changedid/)).to eq(true)
    expect(@cbot2.received_pattern(/ 311.* changedid/)).to eq(true)
  end

end

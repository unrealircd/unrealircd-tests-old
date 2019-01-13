require 'spec_helper'

describe '/OPER command' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
  end

  it 'should reject wrong case of oper name' do
    @swarm.perform do
      @obot.send("OPER NeTaDmIn test")
      sleep(0.5)
    end
    @swarm.execute
    # We expect the command to error (no o lines)
    expect(@obot.received_pattern(/ 491 /)).to eq(true)
    expect(@obot.received_pattern(/ 381 /)).not_to eq(true)
  end

  it 'should reject incorrect host' do
    @swarm.perform do
      @obot.send("OPER netadmin-badhost test")
      sleep(0.5)
    end
    @swarm.execute
    # We expect the command to error (no o lines)
    expect(@obot.received_pattern(/ 491 /)).to eq(true)
    expect(@obot.received_pattern(/ 381 /)).not_to eq(true)
  end

  it 'should reject wrong password' do
    @swarm.perform do
      @obot.send("OPER netadmin TeSt")
      sleep(0.5)
    end
    @swarm.execute
    # We expect the command to error (password incorrect)
    expect(@obot.received_pattern(/ 464 /)).to eq(true)
    expect(@obot.received_pattern(/ 491 /)).not_to eq(true)
    expect(@obot.received_pattern(/ 381 /)).not_to eq(true)
  end

  it 'should accept with correct name, password and hostname' do
    @swarm.perform do
      @obot.send("OPER netadmin test")
      sleep(0.5)
    end
    @swarm.execute
    # We expect the command to succeed (you are now an IRC operator)
    expect(@obot.received_pattern(/ 381 /)).to eq(true)
    expect(@obot.received_pattern(/ 491 /)).not_to eq(true)
  end

end

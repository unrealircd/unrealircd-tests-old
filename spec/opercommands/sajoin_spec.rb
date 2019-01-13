require 'spec_helper'

describe 'SAJOIN command' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
  end

  it 'should disallow SAJOIN to normal users' do
    @swarm.perform do
      @obot.send("SAJOIN obot #test")
      sleep(0.5)
    end
    @swarm.execute
    # We expect the command to error
    expect(@obot.received_pattern(/ 481 /)).to eq(true)
    expect(@obot.received_pattern(/ forced to join /)).not_to eq(true)
  end

  it 'should disallow SAJOIN to opers with insufficient privileges' do
    @swarm.perform do
      @obot.send("OPER globop test")
      @obot.send("SAJOIN obot #test")
      sleep(0.5)
    end
    @swarm.execute
    # We expect the command to error
    expect(@obot.received_pattern(/ 381 /)).to eq(true)
    expect(@obot.received_pattern(/ 481 /)).to eq(true)
    expect(@obot.received_pattern(/ forced to join /)).not_to eq(true)
  end

  it 'should allow SAJOIN to opers with sufficient privileges' do
    @swarm.perform do
      @obot.send("OPER netadmin test")
      @obot.send("SAJOIN obot #test")
      sleep(0.5)
    end
    @swarm.execute
    # We expect the command to error
    expect(@obot.received_pattern(/ 381 /)).to eq(true)
    expect(@obot.received_pattern(/ 481 /)).not_to eq(true)
    expect(@obot.received_pattern(/ forced to join /)).to eq(true)
    expect(@obot.received_pattern(/ 366 obot #test /)).to eq(true)
  end
end

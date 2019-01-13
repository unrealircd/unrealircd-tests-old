require 'spec_helper'

describe 'SAPART command' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
  end

  it 'should disallow SAPART to normal users' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("SAPART obot #test")
      sleep(0.5)
    end
    @swarm.execute
    # We expect the command to error
    expect(@obot.received_pattern(/ 481 /)).to eq(true)
    expect(@obot.received_pattern(/ forced to part /)).not_to eq(true)
  end

  it 'should disallow SAPART to opers with insufficient privileges' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("OPER globop test")
      @obot.send("SAPART obot #test")
      sleep(0.5)
    end
    @swarm.execute
    # We expect the command to error
    expect(@obot.received_pattern(/ 381 /)).to eq(true)
    expect(@obot.received_pattern(/ 481 /)).to eq(true)
    expect(@obot.received_pattern(/ forced to part /)).not_to eq(true)
  end

  it 'should allow SAPART to opers with sufficient privileges' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("OPER netadmin test")
      @obot.send("SAPART obot #test")
      sleep(0.5)
    end
    @swarm.execute
    # We expect the command to error
    expect(@obot.received_pattern(/ 381 /)).to eq(true)
    expect(@obot.received_pattern(/ 481 /)).not_to eq(true)
    expect(@obot.received_pattern(/ forced to part /)).to eq(true)
    expect(@obot.received_pattern(/^:obot.*PART #test/)).to eq(true)
  end
end

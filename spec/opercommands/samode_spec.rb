require 'spec_helper'

describe 'SAMODE command' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
  end

  it 'should disallow SAMODE to normal users' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test -o obot")
      @obot.send("SAMODE #test +k keykeykey")
      sleep(0.5)
    end
    @swarm.execute
    # We expect the command to error
    expect(@obot.received_pattern(/ 481 /)).to eq(true)
    expect(@obot.received_pattern(/:.* MODE.*keykeykey/)).not_to eq(true)
  end

  it 'should disallow SAMODE to opers with insufficient privileges' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test -o obot")
      @obot.send("OPER globop test")
      @obot.send("SAMODE #test +k keykeykey")
      sleep(0.5)
    end
    @swarm.execute
    # We expect the command to error
    expect(@obot.received_pattern(/ 381 /)).to eq(true)
    expect(@obot.received_pattern(/ 481 /)).to eq(true)
    expect(@obot.received_pattern(/:.* MODE.*keykeykey/)).not_to eq(true)
  end

  it 'should allow SAMODE to opers with sufficient privileges' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test -o obot")
      @obot.send("OPER netadmin test")
      @obot.send("SAMODE #test +k keykeykey")
      sleep(0.5)
    end
    @swarm.execute
    # We expect the command to error
    expect(@obot.received_pattern(/ 381 /)).to eq(true)
    expect(@obot.received_pattern(/ 481 /)).not_to eq(true)
    expect(@obot.received_pattern(/:.* MODE.*keykeykey/)).to eq(true)
  end

end

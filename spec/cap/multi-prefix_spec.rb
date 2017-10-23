require 'spec_helper'

describe 'CAP multi-prefix' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot', user: 'xxidentyy')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should show all channel rights in NAMES' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +hv obot obot")
      sleep(0.1)
      @cbot1.send("CAP REQ multi-prefix")
      @cbot1.send("JOIN #test")
      sleep(0.2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/CAP.*ACK.*multi-prefix/)).to eq(true)
    expect(@cbot1.received_pattern(/353.*@%\+obot.*/)).to eq(true)
  end

  it 'should not show all channel rights in NAMES when not requested' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +hv obot obot")
      sleep(0.1)
      @cbot1.send("CAP REQ -multi-prefix")
      @cbot1.send("JOIN #test")
      sleep(0.2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/353.*@%\+obot.*/)).not_to eq(true)
    expect(@cbot1.received_pattern(/353.*@obot.*/)).to eq(true)
  end
end

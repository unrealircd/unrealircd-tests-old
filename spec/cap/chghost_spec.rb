require 'spec_helper'

describe 'CAP chghost' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
    @cbot2 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot2')
  end

  it 'should send CHGHOST to CAP chghost clients' do
    @swarm.perform do
      @cbot1.send("CAP REQ chghost")
      @cbot1.send("JOIN #test")
      @cbot2.send("MODE cbot2 -x")
      @cbot2.send("JOIN #test")
      sleep(3)
      @cbot2.send("MODE cbot2 +x")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/:cbot2.* CHGHOST.*/)).to eq(true)
  end

  it 'should not send CHGHOST to non-CAP-chghost clients' do
    @swarm.perform do
      @cbot1.send("JOIN #test")
      @cbot2.send("MODE cbot2 -x")
      @cbot2.send("JOIN #test")
      @cbot2.send("MODE cbot2 +x")
      sleep(3)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/:cbot2.*CHGHOST.*/)).not_to eq(true)
  end

end

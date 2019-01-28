require 'spec_helper'

describe 'CAP chghost' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @cbot1a = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1a')
    @cbot1b = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1b')
  end

  it 'should send CHGHOST to CAP chghost clients' do
    @swarm.perform do
      @cbot1a.send("CAP REQ chghost")
      @cbot1a.send("JOIN #test")
      @cbot1b.send("MODE cbot1b -x")
      @cbot1b.send("JOIN #test")
      sleep(0.5)
      @cbot1b.send("MODE cbot1b +x")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1a.received_pattern(/:cbot1b.* CHGHOST.*/)).to eq(true)
  end

  it 'should not send CHGHOST to non-CAP-chghost clients' do
    @swarm.perform do
      @cbot1a.send("JOIN #test")
      @cbot1b.send("MODE cbot1b -x")
      @cbot1b.send("JOIN #test")
      @cbot1b.send("MODE cbot1b +x")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1a.received_pattern(/:cbot1b.*CHGHOST.*/)).not_to eq(true)
  end

end

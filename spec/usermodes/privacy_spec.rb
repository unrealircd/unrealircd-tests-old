require 'spec_helper'

describe 'User Mode p (privacy)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    servera = IRC_CONFIG.servers['primary']
    serverb = IRC_CONFIG.servers['secondary']
    @cbot1 = @swarm.fly(server: servera.host, port: servera.port, nick: 'cbot1')
    @cbot2 = @swarm.fly(server: serverb.host, port: serverb.port, nick: 'cbot2')
  end

  it 'should show channel in /WHOIS without umode p' do
    @swarm.perform do
      @cbot1.send("MODE cbot1 -p")
      @cbot1.send("JOIN #secret")
      sleep(0.2)
      @cbot2.send("WHOIS cbot1")
      sleep(0.2)
    end
    @swarm.execute
    expect(@cbot2.received_pattern(/#secret/)).to eq(true)
  end

  it 'should hide channel in /WHOIS with umode p' do
    @swarm.perform do
      @cbot1.send("MODE cbot1 +p")
      @cbot1.send("JOIN #secret")
      sleep(0.2)
      @cbot2.send("WHOIS cbot1")
      sleep(0.2)
    end
    @swarm.execute
    expect(@cbot2.received_pattern(/#secret/)).not_to eq(true)
  end

  it 'should hide channel in /WHO with umode p' do
    @swarm.perform do
      @cbot1.send("MODE cbot1 +p")
      @cbot1.send("JOIN #secret")
      sleep(0.2)
      @cbot2.send("WHO cbot1")
      sleep(0.2)
    end
    @swarm.execute
    expect(@cbot2.received_pattern(/#secret/)).not_to eq(true)
  end

end

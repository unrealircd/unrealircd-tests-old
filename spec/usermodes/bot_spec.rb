require 'spec_helper'

describe 'User Mode B (bot)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    servera = IRC_CONFIG.servers['primary']
    serverb = IRC_CONFIG.servers['secondary']
    @cbot1 = @swarm.fly(server: servera.host, port: servera.port, nick: 'cbot1')
    @cbot2 = @swarm.fly(server: serverb.host, port: serverb.port, nick: 'cbot2')
  end

  it 'should show BOTMOTD upon MODE +B' do
    @swarm.perform do
      @cbot1.send("MODE cbot1 +B")
      sleep(0.2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/BOTMOTD/)).to eq(true)
  end
  
  it 'should show as Bot when doing /WHOIS on yourself' do
    @swarm.perform do
      @cbot1.send("MODE cbot1 +B")
      @cbot1.send("WHOIS cbot1")
      sleep(0.2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/is a \002Bot\002 on/)).to eq(true)
  end

  it 'should show as Bot in /WHOIS performed by another user' do
    @swarm.perform do
      @cbot1.send("MODE cbot1 +B")
      sleep(0.2)
      @cbot2.send("WHOIS cbot1")
      sleep(0.2)
    end
    @swarm.execute
    expect(@cbot2.received_pattern(/is a \002Bot\002 on/)).to eq(true)
  end

end

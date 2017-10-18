require 'spec_helper'

describe 'CAP' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should show parameters with CAP v3.2' do
    @swarm.perform do
      @cbot1.send("CAP LS 302")
      sleep(3)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/:[^ ]+ CAP.* LS :.*=.*/)).to eq(true)
  end

  # This will be screwed up if ircfly issues a CAP 302 by itself in handshake
  # before we do the versionless CAP...
  it 'should not show parameters with versionless CAP' do
    @swarm.perform do
      @cbot1.send("CAP LS")
      sleep(3)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/:[^ ]+ CAP.* LS :.*/)).to eq(true)
    expect(@cbot1.received_pattern(/:[^ ]+ CAP.* LS :.*=.*/)).not_to eq(true)
  end

  # This will be screwed up if ircfly issues a CAP 302 by itself in handshake
  # before we do the versionless CAP...
  it 'should not show parameters with CAP v3.0' do
    @swarm.perform do
      @cbot1.send("CAP LS 300")
      sleep(3)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/:[^ ]+ CAP.* LS :.*/)).to eq(true)
    expect(@cbot1.received_pattern(/:[^ ]+ CAP.* LS :.*=.*/)).not_to eq(true)
  end

  # This will be screwed up if ircfly issues CAP's by itself in handshake.
  it 'should only list requested caps in CAP LIST' do
    @swarm.perform do
      @cbot1.send("CAP LS")
      @cbot1.send("CAP LIST")
      sleep(3)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/:[^ ]+ CAP.* LIST :/)).to eq(true)
  end
end

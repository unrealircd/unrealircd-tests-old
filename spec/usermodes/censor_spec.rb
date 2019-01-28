require 'spec_helper'

describe 'User Mode G (censor)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @cbot1a = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1a')
    @cbot1b = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1b')
  end

  it 'should censor bad words' do
    @swarm.perform do
      @cbot1b.send("MODE cbot1b +G")
      sleep(1)
      @cbot1a.send("PRIVMSG cbot1b :aa fucked bb")
      sleep(1)
    end
    @swarm.execute
    expect(@cbot1b.received_pattern(/fuck/)).not_to eq(true)
    expect(@cbot1b.received_pattern(/aa <censored> bb/)).to eq(true)
  end

  it 'should not censor good words' do
    @swarm.perform do
      @cbot1b.send("MODE cbot1b +G")
      sleep(1)
      @cbot1a.send("PRIVMSG cbot1b :sunshine")
      sleep(1)
    end
    @swarm.execute
    expect(@cbot1b.received_pattern(/sunshine/)).to eq(true)
  end

end

require 'spec_helper'

describe 'User Mode G (censor)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
    @cbot2 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot2')
  end

  it 'should censor bad words' do
    @swarm.perform do
      @cbot2.send("MODE cbot2 +G")
      sleep(0.5)
      @cbot1.send("PRIVMSG cbot2 :aa fucked bb")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot2.received_pattern(/fuck/)).not_to eq(true)
    expect(@cbot2.received_pattern(/aa <censored> bb/)).to eq(true)
  end

  it 'should not censor good words' do
    @swarm.perform do
      @cbot2.send("MODE cbot2 +G")
      sleep(0.5)
      @cbot1.send("PRIVMSG cbot2 :sunshine")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot2.received_pattern(/sunshine/)).to eq(true)
  end

end

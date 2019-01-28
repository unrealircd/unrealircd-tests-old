require 'spec_helper'

describe 'User Mode R (regonlymsg)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @cbot1a = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1a')
    @cbot1b = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1b')
  end

  it 'should block messages from users who are not identified to services' do
    @swarm.perform do
      @cbot1b.send("MODE cbot1b +R")
      sleep(1)
      @cbot1a.send("PRIVMSG cbot1b :good day. this should be blocked.")
      sleep(1)
    end
    @swarm.execute
    expect(@cbot1a.received_pattern(/must identify to a registered nick to private message/)).to eq(true)
    expect(@cbot1b.received_pattern(/this should be blocked/)).not_to eq(true)
  end

  it 'should allow messages from users who are identified to services'
  # TODO. Need services help or helper module.

end

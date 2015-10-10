require 'spec_helper'

describe 'User Mode R (regonlymsg)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
    @cbot2 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot2')
  end

  it 'should block messages from users who are not identified to services' do
    @swarm.perform do
      @cbot2.send("MODE cbot2 +R")
      sleep(2)
      @cbot1.send("PRIVMSG cbot2 :good day. this should be blocked.")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/must identify to a registered nick to private message/)).to eq(true)
    expect(@cbot2.received_pattern(/this should be blocked/)).not_to eq(true)
  end

  it 'should allow messages from users who are identified to services'
  # TODO. Need services help or helper module.

end

require 'spec_helper'

describe 'User Mode W (showwhois)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  # Why do we even have this silly functionality ? 
  it 'should show when someone used /WHOIS' do
    @swarm.perform do
      @obot.send("OPER netadmin test")
      @obot.send("MODE obot +W")
      sleep(0.3)
      @cbot1.send("WHOIS obot")
      sleep(0.2)
    end
    @swarm.execute
    expect(@obot.received_pattern(/cbot1.*did a \/whois on you/)).to eq(true)
  end
end

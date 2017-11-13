require 'spec_helper'

describe 'Spamfilter' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1')
  end

  it 'should (only) block bad words with simple spamfilter' do
    @swarm.perform do
      @obot.send("OPER netadmin test")
      @obot.send("SPAMFILTER add -simple c block 0 spamfilter_test simple*test")
      @obot.send("JOIN #test")
      @cbot1.send("JOIN #test")
      sleep(0.5)
      @cbot1.send("PRIVMSG #test :simple123test")
      @cbot1.send("PRIVMSG #test :othermsg")
      sleep(0.5)
      @obot.send("SPAMFILTER del -simple c block 0 spamfilter_test simple*test")
    end
    @swarm.execute
    expect(@obot.received_pattern(/matches filter.*simple123test/)).to eq(true) #snomask notification
    expect(@obot.received_pattern(/:cbot.*simple123test/)).not_to eq(true) #should not receive chanmsg
    expect(@obot.received_pattern(/:cbot.*othermsg/)).to eq(true) #should receive chanmsg
    expect(@cbot1.received_pattern(/.* 404 cbot1.*spamfilter test/)).to eq(true) # 404 numeric
  end

  it 'should (only) block bad words with regex spamfilter' do
    @swarm.perform do
      @obot.send("OPER netadmin test")
      @obot.send("SPAMFILTER add -regex c block 0 spamfilter_test simple.*test")
      @obot.send("JOIN #test")
      @cbot1.send("JOIN #test")
      sleep(0.5)
      @cbot1.send("PRIVMSG #test :simple123test")
      @cbot1.send("PRIVMSG #test :othermsg")
      sleep(0.5)
      @obot.send("SPAMFILTER del -regex c block 0 spamfilter_test simple.*test")
    end
    @swarm.execute
    expect(@obot.received_pattern(/matches filter.*simple123test/)).to eq(true) #snomask notification
    expect(@obot.received_pattern(/:cbot.*simple123test/)).not_to eq(true) #should not receive chanmsg
    expect(@obot.received_pattern(/:cbot.*othermsg/)).to eq(true) #should receive chanmsg
    expect(@cbot1.received_pattern(/.* 404 cbot1.*spamfilter test/)).to eq(true) # 404 numeric
  end

  it 'should (only) block bad words with posix spamfilter' do
    @swarm.perform do
      @obot.send("OPER netadmin test")
      @obot.send("SPAMFILTER add -posix c block 0 spamfilter_test simple.*test")
      @obot.send("JOIN #test")
      @cbot1.send("JOIN #test")
      sleep(0.5)
      @cbot1.send("PRIVMSG #test :simple123test")
      @cbot1.send("PRIVMSG #test :othermsg")
      sleep(0.5)
      @obot.send("SPAMFILTER del -posix c block 0 spamfilter_test simple.*test")
    end
    @swarm.execute
    expect(@obot.received_pattern(/matches filter.*simple123test/)).to eq(true) #snomask notification
    expect(@obot.received_pattern(/:cbot.*simple123test/)).not_to eq(true) #should not receive chanmsg
    expect(@obot.received_pattern(/:cbot.*othermsg/)).to eq(true) #should receive chanmsg
    expect(@cbot1.received_pattern(/.* 404 cbot1.*spamfilter test/)).to eq(true) # 404 numeric
  end
end

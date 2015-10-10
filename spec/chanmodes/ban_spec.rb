require 'spec_helper'

# Basic ban tests on nick/user/host and on cloaked host, IP, etc.
# Extended bans are not tested here but in their own file.

describe 'Channel Mode b (ban)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1', user: 'bantest')
  end

  it 'should ban if matching nick' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +b cbot1!*@*")
      sleep(1)
      @cbot1.send("JOIN #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/474.*Cannot join/)).to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).not_to eq(true)
  end

  it 'should not ban if not matching nick' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +b cbot999!*@*")
      sleep(1)
      @cbot1.send("JOIN #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/474.*Cannot join/)).not_to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).to eq(true)
  end

  it 'should ban if matching username' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +b *!*bantest@*")
      sleep(1)
      @cbot1.send("JOIN #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/474.*Cannot join/)).to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).not_to eq(true)
  end

  it 'should not ban if not matching username' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +b *!*bantezz@*")
      sleep(1)
      @cbot1.send("JOIN #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/474.*Cannot join/)).not_to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).to eq(true)
  end

  it 'should ban if matching hostname' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +b *!*@localhost")
      sleep(1)
      @cbot1.send("JOIN #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/474.*Cannot join/)).to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).not_to eq(true)
  end

  it 'should not ban if not matching hostname' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +b *!*@localhozz")
      sleep(1)
      @cbot1.send("JOIN #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/474.*Cannot join/)).not_to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).to eq(true)
  end

  it 'should ban if matching exact IP address' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +b *!*@127.0.0.1")
      sleep(1)
      @cbot1.send("JOIN #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/474.*Cannot join/)).to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).not_to eq(true)
  end

  it 'should not ban if not matching exact IP address' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +b *!*@127.0.0.5")
      sleep(1)
      @cbot1.send("JOIN #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/474.*Cannot join/)).not_to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).to eq(true)
  end

  it 'should ban if matching IP address (CIDR)' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +b *!*@127.0.0.0/8")
      sleep(1)
      @cbot1.send("JOIN #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/474.*Cannot join/)).to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).not_to eq(true)
  end

  it 'should not ban if not matching IP address (CIDR)' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +b *!*@128.0.0.0/8")
      sleep(1)
      @cbot1.send("JOIN #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/474.*Cannot join/)).not_to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).to eq(true)
  end

  it 'should still ban if matching hostname even if cloaked' do
    @swarm.perform do
      @cbot1.send("MODE cbot1 +x")
      @obot.send("JOIN #test")
      @obot.send("MODE #test +b *!*@localhost")
      sleep(1)
      @cbot1.send("JOIN #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/474.*Cannot join/)).to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).not_to eq(true)
  end

  it 'should ban on cloaked host when cloaked' do
    @swarm.perform do
      @cbot1.send("MODE cbot1 +x")
      # TODO: fetch cloaked host instead of hardcoding here
      @obot.send("JOIN #test")
      @obot.send("MODE #test +b *!*@Mask-4E7B8307")
      sleep(1)
      @cbot1.send("JOIN #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/474.*Cannot join/)).to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).not_to eq(true)
  end

  it 'should ban on cloaked host when not cloaked too' do
    @swarm.perform do
      @cbot1.send("MODE cbot1 -x")
      # TODO: fetch cloaked host instead of hardcoding here
      @obot.send("JOIN #test")
      @obot.send("MODE #test +b *!*@Mask-4E7B8307")
      sleep(1)
      @cbot1.send("JOIN #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/474.*Cannot join/)).to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).not_to eq(true)
  end

  it 'should ban if matching vhost' do
    @swarm.perform do
      @cbot1.send("VHOST test test")
      @obot.send("JOIN #test")
      @obot.send("MODE #test +b *!*@this.is.a.test")
      sleep(1)
      @cbot1.send("JOIN #test")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/396.*this.is.a.test/)).to eq(true)
    expect(@cbot1.received_pattern(/474.*Cannot join/)).to eq(true)
    expect(@obot.received_pattern(/:cbot1.*JOIN/)).not_to eq(true)
  end

end

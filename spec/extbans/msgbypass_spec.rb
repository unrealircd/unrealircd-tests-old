require 'spec_helper'

describe 'Extended Ban Exception ~m (msgbypass)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
    @cbot1 = @swarm.fly(server: server.host, port: server.port, nick: 'cbot1', user: 'bantest')
  end

  it 'should allow external messages with matching +e ~m:external' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +ne ~m:external:cbot1!*@*")
      sleep(0.5)
      @cbot1.send("PRIVMSG #test :test123")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/.* 404 .*No external.*/)).not_to eq(true)
    expect(@obot.received_pattern(/:cbot1.*PRIVMSG.*test123/)).to eq(true)
  end

  it 'should disallow external messages without matching +e ~m:external' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +ne ~m:external:NOMATCH!*@*")
      sleep(0.5)
      @cbot1.send("PRIVMSG #test :test123")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/.* 404 .*No external.*/)).to eq(true)
    expect(@obot.received_pattern(/:cbot1.*PRIVMSG.*test123/)).not_to eq(true)
  end

  it 'should allow messages with matching +e ~m:moderated' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +me ~m:moderated:cbot1!*@*")
      sleep(0.5)
      @cbot1.send("JOIN #test")
      @cbot1.send("PRIVMSG #test :test123")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/.* 404 .*You need voice.*/)).not_to eq(true)
    expect(@obot.received_pattern(/:cbot1.*PRIVMSG.*test123/)).to eq(true)
  end

  it 'should disallow messages without matching +e ~m:moderated' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +me ~m:moderated:NOMATCH!*@*")
      sleep(0.5)
      @cbot1.send("JOIN #test")
      @cbot1.send("PRIVMSG #test :test123")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/.* 404 .*You need voice.*/)).to eq(true)
    expect(@obot.received_pattern(/:cbot1.*PRIVMSG.*test123/)).not_to eq(true)
  end

  it 'should allow color messages with matching +e ~m:color' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +ce ~m:color:cbot1!*@*")
      sleep(0.5)
      @cbot1.send("JOIN #test")
      @cbot1.send("PRIVMSG #test :\0034test123")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/.* 404 .*You need voice.*/)).not_to eq(true)
    expect(@obot.received_pattern(/:cbot1.*PRIVMSG.*\0034test123/)).to eq(true)
  end

  it 'should disallow color messages without matching +e ~m:color' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +ce ~m:color:NOMATCH!*@*")
      sleep(0.5)
      @cbot1.send("JOIN #test")
      @cbot1.send("PRIVMSG #test :\0034test123")
      sleep(0.5)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/.* 404 .*Color is not permitted.*/)).to eq(true)
    expect(@obot.received_pattern(/:cbot1.*PRIVMSG.*\0034test123/)).not_to eq(true)
  end

  it 'should not filter color messages with matching +e ~m:color' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +Se ~m:color:cbot1!*@*")
      sleep(0.5)
      @cbot1.send("JOIN #test")
      @cbot1.send("PRIVMSG #test :\0034test123")
      sleep(0.5)
    end
    @swarm.execute
    expect(@obot.received_pattern(/:cbot1.*PRIVMSG.*\0034test123/)).to eq(true)
  end

  it 'should filter color messages without matching +e ~m:color' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +Se ~m:color:NOMATCH!*@*")
      sleep(0.5)
      @cbot1.send("JOIN #test")
      @cbot1.send("PRIVMSG #test :\0034test123")
      sleep(0.5)
    end
    @swarm.execute
    expect(@obot.received_pattern(/:cbot1.*PRIVMSG.*\0034test123/)).not_to eq(true)
    expect(@obot.received_pattern(/:cbot1.*PRIVMSG.*:test123/)).to eq(true)
  end

  it 'should not censor messages with matching +e ~m:censor' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +Ge ~m:censor:cbot1!*@*")
      sleep(0.5)
      @cbot1.send("JOIN #test")
      @cbot1.send("PRIVMSG #test :fuck")
      sleep(0.5)
    end
    @swarm.execute
    expect(@obot.received_pattern(/:cbot1.*PRIVMSG.*fuck/)).to eq(true)
    expect(@obot.received_pattern(/:cbot1.*PRIVMSG.*<censored>/)).not_to eq(true)
  end

  it 'should censor messages without matching +e ~m:censor' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +Ge ~m:censor:NOMATCH!*@*")
      sleep(0.5)
      @cbot1.send("JOIN #test")
      @cbot1.send("PRIVMSG #test :fuck")
      sleep(0.5)
    end
    @swarm.execute
    expect(@obot.received_pattern(/:cbot1.*PRIVMSG.*fuck/)).not_to eq(true)
    expect(@obot.received_pattern(/:cbot1.*PRIVMSG.*<censored>/)).to eq(true)
  end

  it 'should not block notices with matching +e ~m:notice' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +Te ~m:notice:cbot1!*@*")
      sleep(0.5)
      @cbot1.send("JOIN #test")
      @cbot1.send("NOTICE #test :test123")
      sleep(0.5)
    end
    @swarm.execute
    expect(@obot.received_pattern(/:cbot1.*NOTICE.*test123/)).to eq(true)
    expect(@cbot1.received_pattern(/.* 404 .*NOTICEs are not permitted.*/)).not_to eq(true)
  end

  it 'should block notices without matching +e ~m:notice' do
    @swarm.perform do
      @obot.send("JOIN #test")
      @obot.send("MODE #test +Te ~m:notice:NOMATCH!*@*")
      sleep(0.5)
      @cbot1.send("JOIN #test")
      @cbot1.send("NOTICE #test :test123")
      sleep(0.5)
    end
    @swarm.execute
    expect(@obot.received_pattern(/:cbot1.*NOTICE.*test123/)).not_to eq(true)
    expect(@cbot1.received_pattern(/.* 404 .*NOTICEs are not permitted.*/)).to eq(true)
  end

end

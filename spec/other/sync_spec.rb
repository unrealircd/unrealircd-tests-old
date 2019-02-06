require 'spec_helper'

# These test the merging of things when servers link
# Currently this tests channels.
# TODO: test users (all user properties, including swhois and such)

describe 'server synching' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    servera = IRC_CONFIG.servers['primary']
    serverb = IRC_CONFIG.servers['secondary']
    hub = IRC_CONFIG.servers['hub']
    @bot1 = @swarm.fly(server: servera.host, port: servera.port, nick: 'bot1')
    @bot2 = @swarm.fly(server: serverb.host, port: serverb.port, nick: 'bot2')
    @bothub = @swarm.fly(server: hub.host, port: hub.port, nick: 'bothub')
  end

  it 'should synch channels correctly (merge)' do
    @swarm.perform do
      @bot1.send("OPER netadmin test")
      @bot2.send("OPER netadmin test")
      @bothub.send("OPER netadmin test")
      @bot1.send("JOIN #test")
      @bot2.send("JOIN #test")
      @bothub.send("JOIN #test")
      sleep(1)
      @bot2.send("PRIVMSG bot1 :before squit") # must always be delivered
      @bot2.send("SQUIT hub.test.net")
      # Now we do our thing
      @bot1.send("MODE #test +bbb lala!lala@ban.number-1.irc1 lala!lala@ban.number-2.irc1 lala!lala@ban.number-3.irc1")
      @bot1.send("MODE #test +eee lala!lala@exempt.number-1.irc1 lala!lala@exempt.number-2.irc1 lala!lala@exempt.number-3.irc1")
      @bot1.send("MODE #test +III lala!lala@invex.number-1.irc1 lala!lala@invex.number-2.irc1 lala!lala@invex.number-3.irc1")
      @bot2.send("MODE #test +bbb lala!lala@ban.number-1.irc2 lala!lala@ban.number-2.irc2 lala!lala@ban.number-3.irc2")
      @bot2.send("MODE #test +eee lala!lala@exempt.number-1.irc2 lala!lala@exempt.number-2.irc2 lala!lala@exempt.number-3.irc2")
      @bot2.send("MODE #test +III lala!lala@invex.number-1.irc2 lala!lala@invex.number-2.irc2 lala!lala@invex.number-3.irc2")
      sleep(1)
      # And we synch again
      @bot2.send("PRIVMSG bot1 :after squit") # must never get delivered
      @bot2.send("CONNECT hub.test.net")
      sleep(2)
      @bot2.send("PRIVMSG bot1 :after reconnect")
      @bot1.send("MODE #test b")
      @bot2.send("MODE #test b")
      @bothub.send("MODE #test b")
      @bot1.send("MODE #test e")
      @bot2.send("MODE #test e")
      @bothub.send("MODE #test e")
      @bot1.send("MODE #test I")
      @bot2.send("MODE #test I")
      @bothub.send("MODE #test I")
      sleep(2)
    end
    @swarm.execute
    # Errors are not expected
    expect(@bot2.received_pattern(/ 481 /)).not_to eq(true)
    # We should receive the 'before squit', this is to ensure the test goes correctly.
    expect(@bot1.received_pattern(/.*PRIVMSG.*before squit/)).to eq(true)
    # We should NOT receive the 'after squit', since servers should not be linked
    expect(@bot1.received_pattern(/.*PRIVMSG.*after squit/)).not_to eq(true)
    # ..we should get an error instead about no such nick:
    expect(@bot2.received_pattern(/:.*401 bot2 bot1/)).to eq(true)
    # We should receive the 'after reconnect', since now we are linked again
    expect(@bot1.received_pattern(/.*PRIVMSG.*after reconnect/)).to eq(true)
    ### Now the real tests:
    # On irc1 we should see the +beI from irc2 being set on synch
    expect(@bot1.received_pattern(/.* MODE .*ban.number-1.irc2.*/)).to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*ban.number-2.irc2.*/)).to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*ban.number-3.irc2.*/)).to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*exempt.number-1.irc2.*/)).to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*exempt.number-2.irc2.*/)).to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*exempt.number-3.irc2.*/)).to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*invex.number-1.irc2.*/)).to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*invex.number-2.irc2.*/)).to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*invex.number-3.irc2.*/)).to eq(true)
    # On irc2 we should see the +beI from irc1 being set on synch
    expect(@bot2.received_pattern(/.* MODE .*ban.number-1.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*ban.number-2.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*ban.number-3.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*exempt.number-1.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*exempt.number-2.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*exempt.number-3.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*invex.number-1.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*invex.number-2.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*invex.number-3.irc1.*/)).to eq(true)
    # On hub we should see the +beI from irc1 being set on synch
    expect(@bothub.received_pattern(/.* MODE .*ban.number-1.irc1.*/)).to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*ban.number-2.irc1.*/)).to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*ban.number-3.irc1.*/)).to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*exempt.number-1.irc1.*/)).to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*exempt.number-2.irc1.*/)).to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*exempt.number-3.irc1.*/)).to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*invex.number-1.irc1.*/)).to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*invex.number-2.irc1.*/)).to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*invex.number-3.irc1.*/)).to eq(true)
    # On all 3 servers we should see the +beI and thanks to SJSBY we should
    # also see the correct setter (the original one)
    # - pitty we can't use a for loop here :(
    # - on bot1/irc1
    expect(@bot1.received_pattern(/367.* \#test.*ban.number-1.irc2 bot2/)).to eq(true)
    expect(@bot1.received_pattern(/367.* \#test.*ban.number-2.irc2 bot2/)).to eq(true)
    expect(@bot1.received_pattern(/367.* \#test.*ban.number-3.irc2 bot2/)).to eq(true)
    expect(@bot1.received_pattern(/348.* \#test.*exempt.number-1.irc2 bot2/)).to eq(true)
    expect(@bot1.received_pattern(/348.* \#test.*exempt.number-2.irc2 bot2/)).to eq(true)
    expect(@bot1.received_pattern(/348.* \#test.*exempt.number-3.irc2 bot2/)).to eq(true)
    expect(@bot1.received_pattern(/346.* \#test.*invex.number-1.irc2 bot2/)).to eq(true)
    expect(@bot1.received_pattern(/346.* \#test.*invex.number-2.irc2 bot2/)).to eq(true)
    expect(@bot1.received_pattern(/346.* \#test.*invex.number-3.irc2 bot2/)).to eq(true)
    expect(@bot1.received_pattern(/367.* \#test.*ban.number-1.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/367.* \#test.*ban.number-2.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/367.* \#test.*ban.number-3.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/348.* \#test.*exempt.number-1.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/348.* \#test.*exempt.number-2.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/348.* \#test.*exempt.number-3.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/346.* \#test.*invex.number-1.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/346.* \#test.*invex.number-2.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/346.* \#test.*invex.number-3.irc1 bot1/)).to eq(true)
    # - on bot2/irc2
    expect(@bot2.received_pattern(/367.* \#test.*ban.number-1.irc2 bot2/)).to eq(true)
    expect(@bot2.received_pattern(/367.* \#test.*ban.number-2.irc2 bot2/)).to eq(true)
    expect(@bot2.received_pattern(/367.* \#test.*ban.number-3.irc2 bot2/)).to eq(true)
    expect(@bot2.received_pattern(/348.* \#test.*exempt.number-1.irc2 bot2/)).to eq(true)
    expect(@bot2.received_pattern(/348.* \#test.*exempt.number-2.irc2 bot2/)).to eq(true)
    expect(@bot2.received_pattern(/348.* \#test.*exempt.number-3.irc2 bot2/)).to eq(true)
    expect(@bot2.received_pattern(/346.* \#test.*invex.number-1.irc2 bot2/)).to eq(true)
    expect(@bot2.received_pattern(/346.* \#test.*invex.number-2.irc2 bot2/)).to eq(true)
    expect(@bot2.received_pattern(/346.* \#test.*invex.number-3.irc2 bot2/)).to eq(true)
    expect(@bot2.received_pattern(/367.* \#test.*ban.number-1.irc1 bot1/)).to eq(true)
    expect(@bot2.received_pattern(/367.* \#test.*ban.number-2.irc1 bot1/)).to eq(true)
    expect(@bot2.received_pattern(/367.* \#test.*ban.number-3.irc1 bot1/)).to eq(true)
    expect(@bot2.received_pattern(/348.* \#test.*exempt.number-1.irc1 bot1/)).to eq(true)
    expect(@bot2.received_pattern(/348.* \#test.*exempt.number-2.irc1 bot1/)).to eq(true)
    expect(@bot2.received_pattern(/348.* \#test.*exempt.number-3.irc1 bot1/)).to eq(true)
    expect(@bot2.received_pattern(/346.* \#test.*invex.number-1.irc1 bot1/)).to eq(true)
    expect(@bot2.received_pattern(/346.* \#test.*invex.number-2.irc1 bot1/)).to eq(true)
    expect(@bot2.received_pattern(/346.* \#test.*invex.number-3.irc1 bot1/)).to eq(true)
    # - on bothub/hub
    expect(@bothub.received_pattern(/367.* \#test.*ban.number-1.irc2 bot2/)).to eq(true)
    expect(@bothub.received_pattern(/367.* \#test.*ban.number-2.irc2 bot2/)).to eq(true)
    expect(@bothub.received_pattern(/367.* \#test.*ban.number-3.irc2 bot2/)).to eq(true)
    expect(@bothub.received_pattern(/348.* \#test.*exempt.number-1.irc2 bot2/)).to eq(true)
    expect(@bothub.received_pattern(/348.* \#test.*exempt.number-2.irc2 bot2/)).to eq(true)
    expect(@bothub.received_pattern(/348.* \#test.*exempt.number-3.irc2 bot2/)).to eq(true)
    expect(@bothub.received_pattern(/346.* \#test.*invex.number-1.irc2 bot2/)).to eq(true)
    expect(@bothub.received_pattern(/346.* \#test.*invex.number-2.irc2 bot2/)).to eq(true)
    expect(@bothub.received_pattern(/346.* \#test.*invex.number-3.irc2 bot2/)).to eq(true)
    expect(@bothub.received_pattern(/367.* \#test.*ban.number-1.irc1 bot1/)).to eq(true)
    expect(@bothub.received_pattern(/367.* \#test.*ban.number-2.irc1 bot1/)).to eq(true)
    expect(@bothub.received_pattern(/367.* \#test.*ban.number-3.irc1 bot1/)).to eq(true)
    expect(@bothub.received_pattern(/348.* \#test.*exempt.number-1.irc1 bot1/)).to eq(true)
    expect(@bothub.received_pattern(/348.* \#test.*exempt.number-2.irc1 bot1/)).to eq(true)
    expect(@bothub.received_pattern(/348.* \#test.*exempt.number-3.irc1 bot1/)).to eq(true)
    expect(@bothub.received_pattern(/346.* \#test.*invex.number-1.irc1 bot1/)).to eq(true)
    expect(@bothub.received_pattern(/346.* \#test.*invex.number-2.irc1 bot1/)).to eq(true)
    expect(@bothub.received_pattern(/346.* \#test.*invex.number-3.irc1 bot1/)).to eq(true)
  end

  it 'should synch channels correctly (different creationtime)' do
    @swarm.perform do
      @bot1.send("OPER netadmin test")
      @bot2.send("OPER netadmin test")
      @bothub.send("OPER netadmin test")
      @bot1.send("JOIN #test")
      @bot2.send("JOIN #test")
      @bothub.send("JOIN #test")
      sleep(1)
      @bot2.send("PRIVMSG bot1 :before squit") # must always be delivered
      @bot2.send("SQUIT hub.test.net")
      # Now we do our thing.. we must ensure we have a different TS though..
      sleep(2)
      @bot2.send("PART #test")
      @bot2.send("JOIN #test")
      # The channel on bot2/irc2 is now newer (higher creationtime) and should loose when we reconnect
      @bot1.send("MODE #test +bbb lala!lala@ban.number-1.irc1 lala!lala@ban.number-2.irc1 lala!lala@ban.number-3.irc1")
      @bot1.send("MODE #test +eee lala!lala@exempt.number-1.irc1 lala!lala@exempt.number-2.irc1 lala!lala@exempt.number-3.irc1")
      @bot1.send("MODE #test +III lala!lala@invex.number-1.irc1 lala!lala@invex.number-2.irc1 lala!lala@invex.number-3.irc1")
      @bot2.send("MODE #test +bbb lala!lala@ban.number-1.irc2 lala!lala@ban.number-2.irc2 lala!lala@ban.number-3.irc2")
      @bot2.send("MODE #test +eee lala!lala@exempt.number-1.irc2 lala!lala@exempt.number-2.irc2 lala!lala@exempt.number-3.irc2")
      @bot2.send("MODE #test +III lala!lala@invex.number-1.irc2 lala!lala@invex.number-2.irc2 lala!lala@invex.number-3.irc2")
      sleep(1)
      # And we synch again
      @bot2.send("PRIVMSG bot1 :after squit") # must never be delivered
      @bot2.send("CONNECT hub.test.net")
      sleep(2)
      @bot2.send("PRIVMSG bot1 :after reconnect")
      @bot1.send("MODE #test b")
      @bot2.send("MODE #test b")
      @bothub.send("MODE #test b")
      @bot1.send("MODE #test e")
      @bot2.send("MODE #test e")
      @bothub.send("MODE #test e")
      @bot1.send("MODE #test I")
      @bot2.send("MODE #test I")
      @bothub.send("MODE #test I")
      sleep(2)
    end
    @swarm.execute
    # Errors are not expected
    expect(@bot2.received_pattern(/ 481 /)).not_to eq(true)
    # We should receive the 'before squit', this is to ensure the test goes correctly.
    expect(@bot1.received_pattern(/.*PRIVMSG.*before squit/)).to eq(true)
    # We should NOT receive the 'after squit', since servers should not be linked
    expect(@bot1.received_pattern(/.*PRIVMSG.*after squit/)).not_to eq(true)
    # ..we should get an error instead about no such nick:
    expect(@bot2.received_pattern(/:.*401 bot2 bot1/)).to eq(true)
    # We should receive the 'after reconnect', since now we are linked again
    expect(@bot1.received_pattern(/.*PRIVMSG.*after reconnect/)).to eq(true)
    ### Now the real tests:
    # On irc1 we should NOT see the +beI from irc2 being set on synch (since they are the loser)
    expect(@bot1.received_pattern(/.* MODE .*ban.number-1.irc2.*/)).not_to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*ban.number-2.irc2.*/)).not_to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*ban.number-3.irc2.*/)).not_to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*exempt.number-1.irc2.*/)).not_to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*exempt.number-2.irc2.*/)).not_to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*exempt.number-3.irc2.*/)).not_to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*invex.number-1.irc2.*/)).not_to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*invex.number-2.irc2.*/)).not_to eq(true)
    expect(@bot1.received_pattern(/.* MODE .*invex.number-3.irc2.*/)).not_to eq(true)
    # On hub we should NOT see the +beI from irc2 being set on synch (since they are the loser)
    expect(@bothub.received_pattern(/.* MODE .*ban.number-1.irc2.*/)).not_to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*ban.number-2.irc2.*/)).not_to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*ban.number-3.irc2.*/)).not_to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*exempt.number-1.irc2.*/)).not_to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*exempt.number-2.irc2.*/)).not_to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*exempt.number-3.irc2.*/)).not_to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*invex.number-1.irc2.*/)).not_to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*invex.number-2.irc2.*/)).not_to eq(true)
    expect(@bothub.received_pattern(/.* MODE .*invex.number-3.irc2.*/)).not_to eq(true)
    # On irc2 we should see the +beI from irc1 being set on synch
    expect(@bot2.received_pattern(/.* MODE .*ban.number-1.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*ban.number-2.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*ban.number-3.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*exempt.number-1.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*exempt.number-2.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*exempt.number-3.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*invex.number-1.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*invex.number-2.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/.* MODE .*invex.number-3.irc1.*/)).to eq(true)
    # And on irc2 we should see our modes removed by the other server (since we are the loser)
    expect(@bot2.received_pattern(/^:hub.*MODE.*ban.number-1.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/^:hub.*MODE.*ban.number-2.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/^:hub.*MODE.*ban.number-3.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/^:hub.*MODE.*exempt.number-1.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/^:hub.*MODE.*exempt.number-2.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/^:hub.*MODE.*exempt.number-3.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/^:hub.*MODE.*invex.number-1.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/^:hub.*MODE.*invex.number-2.irc1.*/)).to eq(true)
    expect(@bot2.received_pattern(/^:hub.*MODE.*invex.number-3.irc1.*/)).to eq(true)
    # On all 3 servers we should see the +beI and thanks to SJSBY we should
    # also see the correct setter (the original one)
    # - note that we should only see the bans set by bot1/irc1. The ones
    #   from bot2/irc2 should not appear in the list as they should be removed
    # - pitty we can't use a for loop here :(
    # - on bot1/irc1
    expect(@bot1.received_pattern(/367.* \#test.*ban.number-1.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/367.* \#test.*ban.number-2.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/367.* \#test.*ban.number-3.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/348.* \#test.*exempt.number-1.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/348.* \#test.*exempt.number-2.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/348.* \#test.*exempt.number-3.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/346.* \#test.*invex.number-1.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/346.* \#test.*invex.number-2.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/346.* \#test.*invex.number-3.irc1 bot1/)).to eq(true)
    expect(@bot1.received_pattern(/367.* \#test.*ban.number-1.irc2 bot2/)).not_to eq(true)
    expect(@bot1.received_pattern(/367.* \#test.*ban.number-2.irc2 bot2/)).not_to eq(true)
    expect(@bot1.received_pattern(/367.* \#test.*ban.number-3.irc2 bot2/)).not_to eq(true)
    expect(@bot1.received_pattern(/348.* \#test.*exempt.number-1.irc2 bot2/)).not_to eq(true)
    expect(@bot1.received_pattern(/348.* \#test.*exempt.number-2.irc2 bot2/)).not_to eq(true)
    expect(@bot1.received_pattern(/348.* \#test.*exempt.number-3.irc2 bot2/)).not_to eq(true)
    expect(@bot1.received_pattern(/346.* \#test.*invex.number-1.irc2 bot2/)).not_to eq(true)
    expect(@bot1.received_pattern(/346.* \#test.*invex.number-2.irc2 bot2/)).not_to eq(true)
    expect(@bot1.received_pattern(/346.* \#test.*invex.number-3.irc2 bot2/)).not_to eq(true)
    # TODO: other servers..
  end

end

require 'spec_helper'

# This test checks if the 005 tokens are present

describe '005 numeric' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    servera = IRC_CONFIG.servers['primary']
    serverb = IRC_CONFIG.servers['secondary']
    hub = IRC_CONFIG.servers['hub']
    @bot1 = @swarm.fly(server: servera.host, port: servera.port, nick: 'bot1')
    @bot2 = @swarm.fly(server: serverb.host, port: serverb.port, nick: 'bot2')
  end

  it 'should contain expected 005 tokens' do
    @swarm.perform do
      # We don't have to do anything, actually
    end
    @swarm.execute
    # I considered using generic value matchers such as CHANMODES=.+,.+,.+,.+
    # However it is probably a good idea to be notified of such changes since
    # they don't happen much and may be unintended.
    expect(@bot1.received_pattern(/ 005 .* AWAYLEN=307.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* AWAYLEN=307.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* CASEMAPPING=ascii.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* CASEMAPPING=ascii.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* CHANLIMIT=#:10.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* CHANLIMIT=#:10.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* CHANMODES=beI,kLf,l,psmntirzMQNRTOVKDdGPZSCc.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* CHANMODES=beI,kLf,l,psmntirzMQNRTOVKDdGPZSCc.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* CHANNELLEN=32.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* CHANNELLEN=32.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* CHANTYPES=#.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* CHANTYPES=#.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* DEAF=d.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* DEAF=d.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* ELIST=MNUCT.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* ELIST=MNUCT.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* EXCEPTS.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* EXCEPTS.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* EXTBAN=~,tmTSOcaRrnqj.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* EXTBAN=~,tmTSOcaRrnqj.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* HCN.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* HCN.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* INVEX.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* INVEX.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* KICKLEN=307.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* KICKLEN=307.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* KNOCK.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* KNOCK.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* MAP.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* MAP.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* MAXCHANNELS=10.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* MAXCHANNELS=10.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* MAXLIST=b:60,e:60,I:60.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* MAXLIST=b:60,e:60,I:60.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* MAXNICKLEN=30.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* MAXNICKLEN=30.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* MODES=12.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* MODES=12.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* NAMESX.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* NAMESX.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* NETWORK=TestNet.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* NETWORK=TestNet.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* NICKLEN=30.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* NICKLEN=30.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* PREFIX=\(qaohv\)~&@%+.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* PREFIX=\(qaohv\)~&@%+.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* QUITLEN=307.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* QUITLEN=307.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* SAFELIST.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* SAFELIST.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* SILENCE=15.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* SILENCE=15.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* STATUSMSG=~&@%+.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* STATUSMSG=~&@%+.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* TARGMAX=DCCALLOW:,ISON:,JOIN:,KICK:4,KILL:,LIST:,NAMES:1,NOTICE:1,PART:,PRIVMSG:4,SAJOIN:,SAPART:,USERHOST:,USERIP:,WATCH:,WHOIS:1,WHOWAS:1.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* TARGMAX=DCCALLOW:,ISON:,JOIN:,KICK:4,KILL:,LIST:,NAMES:1,NOTICE:1,PART:,PRIVMSG:4,SAJOIN:,SAPART:,USERHOST:,USERIP:,WATCH:,WHOIS:1,WHOWAS:1.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* TOPICLEN=360.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* TOPICLEN=360.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* UHNAMES.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* UHNAMES.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* USERIP.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* USERIP.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* WALLCHOPS.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* WALLCHOPS.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* WATCH=128.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* WATCH=128.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* WATCHOPTS=A.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* WATCHOPTS=A.*/)).to eq(true)
    expect(@bot1.received_pattern(/ 005 .* WHOX.*/)).to eq(true)
    expect(@bot2.received_pattern(/ 005 .* WHOX.*/)).to eq(true)
  end
end

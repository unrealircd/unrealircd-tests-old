require 'spec_helper'

describe 'Channel Mode P (permanent)' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    server = IRC_CONFIG.servers['primary']
    @obot = @swarm.fly(server: server.host, port: server.port, nick: 'obot')
  end

  it 'should result in persistent channel modes' do
    @swarm.perform do
      @obot.send("OPER netadmin test")
      @obot.send("JOIN #perm")
      @obot.send("MODE #perm +PTbeI ban!*@* exempt!*@* invex!*@*")
      @obot.send("PART #perm")
      @obot.send("JOIN #perm")
      @obot.send("MODE #perm")
      @obot.send("MODE #perm +b")
      @obot.send("MODE #perm +e")
      @obot.send("MODE #perm +I")
      sleep(0.5)
      @obot.send("MODE #perm -PTbeI ban!*@* exempt!*@* invex!*@*")
    end
    @swarm.execute
    # Channel modes (+PT)
    expect(@obot.received_pattern(/324 obot \#perm \+TP/)).to eq(true)
    # Ban
    expect(@obot.received_pattern(/367 obot \#perm ban\!\*@\*/)).to eq(true)
    # Exempt
    expect(@obot.received_pattern(/348 obot \#perm exempt\!\*@\*/)).to eq(true)
    # Invex
    expect(@obot.received_pattern(/346 obot \#perm invex\!\*@\*/)).to eq(true)
  end

  it 'should result in persistent topic' do
    @swarm.perform do
      @obot.send("OPER netadmin test")
      @obot.send("JOIN #perm")
      @obot.send("MODE #perm +P")
      @obot.send("TOPIC #perm :test 123")
      @obot.send("PART #perm")
      @obot.send("JOIN #perm")
      sleep(0.5)
      @obot.send("MODE #perm -P")
      @obot.send("TOPIC #perm :")
    end
    @swarm.execute

    expect(@obot.received_pattern(/332 obot \#perm :test 123/)).to eq(true)
  end

end

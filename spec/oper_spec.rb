require 'spec_helper'

describe 'Oper' do
  it 'should reject unauthorized users' do
    swarm = Ircfly::Swarm.new
    bot = swarm.fly(server: 'irc.ecnet.org', nick: 'testbot')
    swarm.perform do
      bot.send('JOIN #test')
      sleep(1)
    end
    swarm.execute
  end

  it 'should reject bad passwords'
  it 'should reject bad hosts with good passwords'
  it 'should permit good hosts, users, and passwords'
end

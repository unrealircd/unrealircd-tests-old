require 'spec_helper'

describe 'Oper' do
  it 'should reject unauthorized users' do
    swarm = Ircfly::Swarm.new
    bot = swarm.fly(server: 'irc.example.com', nick: 'testbot')
    swarm.perform do
      bot.send('JOIN #test')
      sleep(4)
      expect(bot.oper?).to be(false)
      bot.quit
    end
    swarm.execute
  end

  it 'should reject bad passwords'
  it 'should reject bad hosts with good passwords'
  it 'should permit good hosts, users, and passwords'
end

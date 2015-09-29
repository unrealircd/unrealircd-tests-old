require 'spec_helper'

describe 'Channel Mode D/d' do
  before(:each) do
    @swarm = Ircfly::Swarm.new
    @test_channel = '#test'
    @obot = @swarm.fly(server: IRC_SERVER, nick: 'obot')
    @cbot1 = @swarm.fly(server: IRC_SERVER, nick: 'cbot1')
    @cbot2 = @swarm.fly(server: IRC_SERVER, nick: 'cbot2')
  end

  it 'should not show users joining a mode +d channel' do
    @swarm.perform do
      @obot.send("JOIN #{@test_channel}")
      sleep(1)
      channel = @obot.channel_with_name(@test_channel)
      channel.mode('+D')
      @cbot1.send("JOIN #{@test_channel}")
      @cbot2.send("JOIN #{@test_channel}")
      sleep(2)
    end
    @swarm.execute
    expect(@cbot1.received_pattern(/cbot2/)).to eq(false)
    expect(@cbot2.received_pattern(/cbot1/)).to eq(false)
  end

  it 'should show operators joining a mode +d channel'
  it 'should show operators when promoted after joining a mode +d channel'
  it 'should show a user after they speak in a mode +d channel'
  it 'should keep mode +D after -d until all hidden users leave or are shown'
end

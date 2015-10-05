$:<< File.join(File.dirname(__FILE__), '..')
require 'ircfly'
require 'ircfly/fly'
require 'irc_config.rb'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  Kernel.srand config.seed
end

IRC_CONFIG = IrcConfig.new('config.yaml')

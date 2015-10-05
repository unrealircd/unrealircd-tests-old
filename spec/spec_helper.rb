require 'ircfly'
require 'ircfly/fly'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  Kernel.srand config.seed
end

IRC_SERVER='irc.example.com'
IRC_PORT=6667

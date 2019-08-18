## About
This is the OLD automated test system for UnrealIRCd 4 (ruby-based).
The new test framework can be found at https://github.com/unrealircd/unrealircd-tests

This will test a subset of features. The ultimate goal is to have a test for each and every feature.
Right now we have tests for (almost) all channel modes and user modes but almost none for commands.

## Installation instructions

### Install python and bundler
* `apt-get install python` or `yum install python`
* `sudo gem install bundler`

### Install the IRC test framework (ircfly)
```
git co https://github.com/unrealircd/ircfly.git
cd ircfly
bundle install
rake build
sudo rake install
cd ..
```

### Checkout the unrealircd-tests
```
git co https://github.com/unrealircd/unrealircd-tests.git
cd unrealircd-tests
bundle install
```

### Configure unrealircd-tests and your IRC server
* `cp config.yaml.example config.yaml`
* Now edit config.yaml to point it to your test IRC server. By default it assumes an ircd on port 5667.
* In the ircdconfig/ directory are files that you should include in your UnrealIRCd. They contain things like oper blocks and vhost blocks that will be used by tests.

### Running tests
* Try running an indiviaul test like: `rspec spec/chanmodes/noctcp_spec.rb`
* To run all tests you simply run `rake`. This takes several minutes to complete.

## Expected test output
You will see the raw IRC traffic (in and out). At the end it will say something like:
```
Finished in 4.08 seconds (files took 0.24379 seconds to load)
1 example, 0 failures
```

Obviously, the most important is the '0 failures' part.

## Writing tests
We could really use a lot more tests, so if you want to help out, please do.

Check out a few tests in the spec/ directory. Feel free to copy one and then create a new test based on it.

Tests:
* `spec/chanmodes/` - Channel modes
* `spec/usermodes/` - User modes
* `spec/extbans/` - Extended bans
* `spec/cap` - CAP (client protocol negotiation)
* `spec/usercommands/` - User commands, such as JOIN PART TOPIC etc.
* `spec/opercommands/` - IRCOp-only commands, such as SAJOIN SAPART KILL etc.
* `spec/other/` - Other tests that do not fit in the above categories.

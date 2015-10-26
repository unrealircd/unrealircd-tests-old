## About
These are the automated tests for UnrealIRCd. They will test various features.
Our ultimate goal is to have a test for each and every feature.

Right now we have tests for (almost) all channel modes and user modes but almost none for all the commands.

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
Finished in 4.08 seconds (files took 0.24379 seconds to load)
1 example, 0 failures

The most important is the '0 failures' part.

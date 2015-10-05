require 'yaml'

class IrcConfig
  class IrcServer
    attr_reader :host
    attr_reader :port
    attr_reader :password
    attr_reader :ssl_port

    def initialize(server: nil, host: 'irc.example.org', port: 6667, ssl_port: 6697, password: nil)
      unless server.nil?
        (@host,@port) = server.split(':')
      else
        @host = host
        @port = port
      end

      @password = password
      @ssl_port = ssl_port
    end

  end

  attr_reader :servers
  attr_reader :options

  def initialize(file_path)
    configuration = YAML.load_file(file_path)
    @options = configuration['Options']
    @servers = Hash.new
    configuration['Servers'].each do |name, entry|
      @servers[name] = IrcServer.new(server: entry['server'], host: entry['host'], port: entry['port'], ssl_port: entry['ssl_port'], password: entry['password'])
    end
  end
end

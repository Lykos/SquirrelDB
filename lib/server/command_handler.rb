require 'connect_id'

class CommandHandler

  def initialize(inn, out, err, connection, options)
    @in = inn
    @out = out
    @err = err
    @connection = connection
    @options = options
  end

  def is_command?(line)
    line.start_with?(COMMAND_PREFIX)
  end

  def handle(line)
    command, *options = line[COMMAND_PREFIX.length..-1].split(/\s+/)
    @out.puts "Got client command: #{command}"
    COMMANDS.each do |c, aliases|
      if aliases.include?(command.downcase)
        method(c).call(*options)
        break
      end
    end
  end

  private

  COMMAND_PREFIX = "/"

  COMMANDS = {
    :quit => ["q", "quit", "exit"],
    :connect => ["c", "connect"],
    :disconnect => ["d", "disconnect"]
  }

  def quit(*args)
    @connection.disconnect if @connection.connected?
    @out.puts "Closing session."
    exit(0)
  end

  def disconnect(*args)
    if @connection.connected?
      @connection.disconnect
    else
      @out.puts "Not connected!"
    end
  end

  def connect(*args)
    options = {}
    connections = args.select { |arg| ConnectId::PATTERN.match(arg) }
    if connections.length == 0
      @out.puts "No connection specified."
      return
    elsif connections.length > 1
      @out.puts "More than one connection specified."
      return
    end
    args.delete(connections[0])
    connect_id = ConnectId.parse(connections[0])
    OptionParser.new do |opts|
      opts.on("-p", "--port N", Integer, "Use port N") do |p|
        options[:port] = p
      end

      opts.on("-h", "--help") do |h|
        @out.puts opts
        return
      end
    end.parse!(args)

    @connection.disconnect if @connection.connected?
    @connection.connect(connect_id.user || @options[:user], connect_id.hostname || @options[:hostname], options[:port] || @options[:port])
  end

end

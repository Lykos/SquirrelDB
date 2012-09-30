require 'socket'
require 'crypto/client_socket'

include Crypto

class ClientConnection

  def self.open(log, aliases, public_key_callback)
    lsio = new(log, aliases, public_key_callback)
    return lsio unless block_given?
    begin
      yield(lsio)
    ensure
      lsio.disconnect if lsio.connected?
    end
  end

  def initialize(log, aliases, validate_key)
    @log = log
    @aliases = aliases
    @validate_key = validate_key
    @connected = false
  end

  attr_reader :connected, :client_socket

  alias :connected? :connected

  def disconnect
    raise "Connection is already closed." if !connected?
    internal_disconnect
    @log.puts "Connection closed."
  end

  def connect(user, hostname, port)
    raise "Connection is already open." if connected?
    @log.puts "Connecting to #{user}@#{hostname}. This may take a while."
    if @aliases.has_key?(hostname)
      alias_info = @aliases[hostname]
      hostname = alias_info[:hostname] || hostname
      user = alias_info[:user] || user
    end
    begin
      @socket = TCPSocket.new(hostname, port)
      @client_socket = ClientSocket.new(@socket, lambda { |key| @validate_key.call(hostname, key) })
      @log.puts "Connected."
      @connected = true
    rescue IOError
      @log.puts "Could not establish connection"
      internal_disconnect
    end
  end

  def request(message)
    raise "Not connected." if !connected?
    begin
      @client_socket.puts(":" + message)
      @client_socket.gets
    rescue IOError
      @log.puts "Connection to server lost."
      internal_disconnect rescue IOError
    end
  end

  private

  def internal_disconnect
    @connected = false
    begin
      begin
        begin
          @client_socket.puts("close") if @client_socket && @client_socket.writable?
        ensure
          @client_socket.close if @client_socket && !@client_socket.closed?
        end
      ensure
        @socket.close if @socket && !@socket.closed?
      end
    rescue IOError => e
      @log.puts "Ignored error:", e, *e.backtrace
    end
  end

end

module SquirrelDB

  module Client
  
    # Represents the connection information consisting of the username and the hostname
    # Used as an Argument class for Optparse.
    class ConnectId

      PATTERN = /^\s*(?:(?<user>\w*)@)?(?<host>\w+)\s*$/
    
      def self.parse(string)
        matches = PATTERN.match(string)
        if matches
          ConnectId.new(matches[:user], matches[:host])
        else
          nil
        end
      end
      
      attr_reader :user, :host
      
      protected
      
      def initialize(user, host)
        @user = user
        @host = host
      end
  
    end
    
  end

end

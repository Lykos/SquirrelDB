require 'errors/internal_error'

module SquirrelDB

  # Thrown if the parser is in an invalid state, but it is not the users fault.
  class InternalParserError < InternalError
    
  end

end

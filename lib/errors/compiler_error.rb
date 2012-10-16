require 'errors/internal_error'

module SquirrelDB

  # Thrown if the compiler fails, but it is not the users fault.
  class CompilerError < InternalError
    
  end

end

module SquirrelDB

  # Represents errors that result from invalid user input. They should usually be catched.
  # Even if they are a result from internal operations, they should be catched and transformed
  # to another error.
  class UserError < StandardError
    
  end

end

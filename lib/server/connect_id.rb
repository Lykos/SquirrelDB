class ConnectId < Struct.new(:user, :hostname)

  PATTERN = /^\s*(?:(?<user>\w*)@)?(?<hostname>\w+)\s*$/

  def self.parse(string)
    matches = PATTERN.match(string)
    ConnectId.new(matches[:user], matches[:hostname])
  end

end

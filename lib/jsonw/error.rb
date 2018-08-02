module JsonW
  Error = Class.new(StandardError)

  ParseError = Class.new(Error)
  GeneratorError = Class.new(Error)
end

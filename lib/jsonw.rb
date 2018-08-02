require "jsonw/version"
require "jsonw/error"
require "jsonw/parser"
require "jsonw/generator"

module JsonW
  # Your code goes here...
  def parse(json)
    JsonW::Parser.new.parse(json)
  end

  module_function :parse
end

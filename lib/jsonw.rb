require "jsonw/version"
require "jsonw/error"
require "jsonw/parser"
require "jsonw/generator"

module JsonW
  SPECIAL = {
    '"' => '"',
    '\\' => "\\",
    '/' => "/",
    'b' => "\b",
    'f' => "\f",
    'n' => "\n",
    'r' => "\r",
    't' => "\t"
  }.freeze

  SPECIAL_REVERSE = SPECIAL.map{ |k, v| [v, "\\#{k}"] }.to_h.freeze

  # Your code goes here...
  def parse(json)
    JsonW::Parser.new.parse(json)
  end
  module_function :parse

  def dump(obj)
    JsonW::Generator.new.dump(obj)
  end
  module_function :dump
end

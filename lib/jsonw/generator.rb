# frozen_string_literal: true

module JsonW
  class Generator
    SPECIAL_MATCHER = /["\/\\\t\n\f\b\r]/

    def initialize
    end

    def dump(val)
      @builder = String.new

      dump_value!(val)

      @builder
    end

    private

    def dump_value!(value)
      if value.is_a? String
        @builder << value.inspect
      elsif value == true || value == false || value.is_a?(Integer) || value.is_a?(Float)
        @builder << value.inspect
      elsif value.nil?
        @builder << 'null'
      elsif value.is_a? Hash
        @builder << '{'

        first = true
        value.each_pair do |k, val|
          @builder << ',' unless first

          @builder << k.to_s.inspect
          @builder << ':'
          dump_value!(val)

          first = false
        end

        @builder << '}'
      elsif value.is_a? Array
        @builder << '['

        first = true
        value.each do |val|
          @builder << ',' unless first
          dump_value!(val)
          first = false
        end

        @builder << ']'
      else
        if value.respond_to?(:to_json)
          @builder << value.to_json
        else
          @builder << value.to_s.inspect.gsub(SPECIAL_MATCHER, SPECIAL_REVERSE)
        end
      end
    end
  end
end

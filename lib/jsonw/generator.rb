# frozen_string_literal: true

module JsonW
  class Generator
    SPECIAL_MATCHER = /[\/\\\t\n\f\b\r]/

    def initialize
    end

    def dump(val)
      @builder = String.new

      dump_value!(val)

      @builder
    end

    private

    def dump_value!(value)
      if value.is_a?(String) || value.is_a?(Integer) || value.is_a?(Float) || value == true || value == false
        @builder << value.inspect
      elsif value.nil?
        @builder << 'null'
      elsif value.is_a? Hash
        build_hash!(value)
      elsif value.is_a? Array
        build_array!(value)
      else
        if value.respond_to?(:to_json)
          @builder << value.to_json
        else
          @builder << value.to_s.inspect.gsub(SPECIAL_MATCHER, SPECIAL_REVERSE)
        end
      end
    end

    def build_hash!(value)
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
    end

    def build_array!(value)
      @builder << '['

      first = true
      value.each do |val|
        @builder << ',' unless first
        dump_value!(val)
        first = false
      end

      @builder << ']'
    end
  end
end

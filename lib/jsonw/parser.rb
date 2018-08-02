# frozen_string_literal: true

module JsonW
  class Parser
    BLANK_SPACE = /\s*/m
    UNICODE = /\A\h{4}\z/
    STRING_MATCHER = /([^\\"]*)(\\|")/
    NUMBER_MATCHER = /\A-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?\z/
    TERMINATOR = /([\s\}\],]|\z)/

    def initialize
      @mutex = Mutex.new
    end

    def parse(data)
      @mutex.synchronize do
        raise ParseError.new("Must pass JSON string to parse") unless data.is_a? String

        @index = 0
        @data = data

        val = parse_value
        if @index == @data.length
          val
        else
          raise ParseError.new("Unexpected token")
        end
      end
    end

    private

    def parse_value
      skip_blank!

      case @data[@index]
      when 'n', 't', 'f'
        parse_token
      when /[\d-]/
        parse_number
      when '{'
        parse_hash
      when '['
        parse_array
      when '"'
        parse_string
      when nil
        raise ParseError.new("Value can't be blank")
      else
        puts @data[0..(@index + 5)]
        raise ParseError.new("Unknown token `#{@data[@index]}'")
      end
    end

    def parse_string
      # Skip leading '"'
      @index += 1

      str = String.new
      loop do
        match = @data.match(STRING_MATCHER, @index)
        raise ParseError.new("Could not parse string") unless match

        str << match[1]

        @index += match[0].length

        if match[2] == '"'
          return str
        else
          char = @data[@index]
          @index += 1

          if SPECIAL.key?(char)
            str << SPECIAL[char]
          elsif char == 'u'
            str << unicode(@data[@index, 4])
            @index += 4
          else
            raise ParseError.new("Unable to parse string escape sequence")
          end
        end
      end
    end

    def parse_number
      stop = @data.index(TERMINATOR, @index)
      number = @data[@index, stop - @index]
      @index = stop

      raise ParseError.new("`#{number}' is not a valid number") unless number.match? NUMBER_MATCHER

      # Yes, I feel **really** dirty for doing this
      eval number
    end

    def parse_hash
      # Skip leading '{'
      @index += 1
      hash = Hash.new

      skip_blank!
      if @data[@index] == '}'
        @index += 1
        return hash
      end

      loop do
        skip_blank!

        key = parse_string.freeze
        skip_blank!(':')
        hash[key] = parse_value

        skip_blank!
        char = @data[@index]
        @index += 1

        if char == '}'
          return hash
        elsif char != ','
          raise ParseError.new("expected a comma in hash")
        end
      end
    end

    def parse_array
      # Skip leading '['
      @index += 1
      array = Array.new

      skip_blank!
      if @data[@index] == ']'
        @index += 1
        return array
      end

      loop do
        skip_blank!

        array << parse_value

        skip_blank!
        char = @data[@index]
        @index += 1

        if char == ']'
          return array
        elsif char != ','
          raise ParseError.new("expected a comma in array")
        end
      end
    end

    def parse_token
      if @data[@index, 4] == 'null'
        @index += 4
        nil
      elsif @data[@index, 4] == 'true'
        @index += 4
        true
      elsif @data[@index, 5] == 'false'
        @index += 5
        false
      else
        raise ParseError.new("Unrecognized token")
      end
    end

    # Even more private

    def skip_blank!(sep = nil)
      @index += @data.match(BLANK_SPACE, @index)[0].length
      raise ParseError.new("FORM FEED NOT SUPPORTED") if @data[@index] == "\f"

      unless sep.nil?
        raise ParseError.new("`#{sep}' did not follow in parsing") unless @data[@index, sep.length] == sep

        @index += sep.length
        skip_blank!
      end
    end

    def unicode(str)
      raise ParseError.new("Unicode standard not met") unless str.match? UNICODE

      [str.each_char.inject(0){ |m, c| (m << 4) + c.hex }].pack('U')
    end
  end
end

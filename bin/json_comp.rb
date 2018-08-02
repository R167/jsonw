#!/usr/bin/env ruby
# frozen_string_literal: true

require 'oj'
require 'json'
require 'json/pure/parser'
require 'json/pure/generator'
require 'benchmark/ips'
require 'msgpack'
require 'yajl'
require 'jsonw'
require 'securerandom'

data = {}
20.times do |n|
  data[SecureRandom.uuid] = rand(0..n).times.map do |num|
    if num % 2 == 0
      num.times.to_a
    else
      num.times.each_with_index.map do |x, i|
        [x, i.times.map{SecureRandom.uuid.sub('-', '\n').sub('-', '\u00A9').sub('-', '\t')}]
      end.to_h
    end
  end
end

json = Oj.dump(data)
msg = MessagePack.pack(data)

size = json.length

COMPARISONS = {
  "JsonW" => {
    dump: proc {JsonW.dump(data)},
    parse: proc {JsonW.parse(json)}
  },
  "JSON" => {
    dump: proc {JSON.fast_generate(data)},
    parse: proc {JSON.parse(json)},
    setup: proc {
      JSON.generator = JSON::Ext::Generator
      JSON.parser = JSON::Ext::Parser
    }
  },
  "JSON::Pure" => {
    dump: proc {JSON.fast_generate(data)},
    parse: proc {JSON.parse(json)},
    setup: proc {
      JSON.generator = JSON::Pure::Generator
      JSON.parser = JSON::Pure::Parser
    }
  },
  "Yajl" => {
    dump: proc {Yajl::Encoder.encode(data)},
    parse: proc {Yajl::Parser.parse(json)}
  },
  "Oj" => {
    dump: proc {Oj.dump(data)},
    parse: proc {Oj.load(json)}
  },
  "MessagePack" => {
    dump: proc {MessagePack.pack(data)},
    parse: proc {MessagePack.unpack(msg)},
    msgpack: true
  }
}

def bench(size:, dump:, msgpack: false)
  puts "Benchmarking #{dump ? 'generating' : 'parsing'} a #{size} byte JSON doc"

  key = dump ? :dump : :parse

  Benchmark.ips do |x|

    COMPARISONS.each_pair do |name, meta|
      next if meta[:msgpack] && !msgpack

      x.report(name) do |c|
        meta[:setup]&.call

        c.times(&meta[key])
      end
    end

    x.compare!
  end
end

bench(size: size, dump: true)
puts
bench(size: size, dump: false)

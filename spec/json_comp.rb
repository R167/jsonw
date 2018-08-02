#!/usr/bin/env ruby

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

puts json.length

dump = true
msgpack = false

Benchmark.ips do |x|
  x.report "JsonW" do |c|
    if dump
      c.times { JsonW.dump(data) }
    else
      c.times { JsonW.parse(json) }
    end
  end

  x.report "JSON" do |c|
    JSON.generator = JSON::Ext::Generator
    JSON.parser = JSON::Ext::Parser

    if dump
      c.times { JSON.fast_generate(data) }
    else
      c.times { JSON.parse(json) }
    end
  end

  x.report "JSON::Pure" do |c|
    JSON.generator = JSON::Pure::Generator
    JSON.parser = JSON::Pure::Parser

    if dump
      c.times { JSON.fast_generate(data) }
    else
      c.times { JSON.parse(json) }
    end
  end

  x.report "Yajl" do |c|
    if dump
      c.times { Yajl::Encoder.encode(data) }
    else
      c.times { Yajl::Parser.parse(json) }
    end
  end

  x.report "Oj" do |c|
    if dump
      c.times { Oj.dump(data) }
    else
      c.times { Oj.load(json) }
    end
  end

  if msgpack
    x.report "MessagePack" do |c|
      if dump
        c.times { MessagePack.pack(data) }
      else
        c.times { MessagePack.unpack(msg) }
      end
    end
  end

  x.compare!
end

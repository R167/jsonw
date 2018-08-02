# JsonW

For a while now, I've always enjoyed looking at the simplicity of the [JSON spec](http://www.json.org/)
and always had a nagging feeling that I wanted to try implementing it. Lately, for one reason or another,
I've been looking at other Ruby JSON implementations such as [Yajl](https://github.com/brianmario/yajl-ruby),
[Oj](https://github.com/ohler55/oj), Ruby's [JSON](https://github.com/flori/json) implementation, and
[Fast JSON API](https://github.com/Netflix/fast_jsonapi), as well as [MessagePack](https://github.com/msgpack/msgpack-ruby).

TL;DR: I got bored so I decided to try my hand at implementing a standard like this from the provided
spec and see how I did. Additionally, I'm looking at it as a learning opportunity for implementing a (planned)
version in C or Rust: creating a gem with native extensions.

Long Story short: this is all more of a learning exercise than anything else. Don't expect the code to
be perfect or even think it's a good idea to use it, but if you're curious, feel free to have a look around.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jsonw'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jsonw

## Usage

The gem currently has no options, though the simplest way to use it at the moment is:

```ruby
# Generating JSON
JsonW.dump({author: "Winston", "numbers" => [1, 2, 3/4r, 7.5]})
# => '{"author":"Winston","numbers":[1,2,"3\/4",7.5]}'

# Parsing JSON
JsonW.parse('{"author":"Winston","numbers":[1,2,\"3\/4\",7.5]}')
# => {"author"=>"Winston", "numbers"=>[1, 2, "3/4", 7.5]}
```

## Speed Results

Running some basic specs from `bin/json_comp.rb`, the parsing is... passable (about 3.5x slower than `JSON::Pure`),
especially considering it's a fairly naive approach in Ruby. Generating isn't overall too bad though (about 2x slower
than compiled `JSON` due to certain optimizations of only calling `#to_json` when no other choice).

Parsing:
```
Benchmarking parsing a 18254 byte JSON doc
Warming up --------------------------------------
               JsonW    10.000  i/100ms
                JSON   190.000  i/100ms
          JSON::Pure    23.000  i/100ms
                Yajl   259.000  i/100ms
                  Oj   463.000  i/100ms
Calculating -------------------------------------
               JsonW     93.446  (± 4.3%) i/s -    470.000  in   5.040820s
                JSON      2.725k (± 6.4%) i/s -     13.680k in   5.042823s
          JSON::Pure    256.247  (± 2.7%) i/s -      1.288k in   5.030124s
                Yajl      3.002k (± 2.6%) i/s -     15.022k in   5.007733s
                  Oj      5.370k (± 1.8%) i/s -     26.854k in   5.002415s

Comparison:
                  Oj:     5369.9 i/s
                Yajl:     3001.8 i/s - 1.79x  slower
                JSON:     2725.2 i/s - 1.97x  slower
          JSON::Pure:      256.2 i/s - 20.96x  slower
               JsonW:       93.4 i/s - 57.47x  slower
```

Dumping:
```
Benchmarking generating a 18254 byte JSON doc
Warming up --------------------------------------
               JsonW   143.000  i/100ms
                JSON   291.000  i/100ms
          JSON::Pure    39.000  i/100ms
                Yajl   710.000  i/100ms
                  Oj     1.438k i/100ms
Calculating -------------------------------------
               JsonW      1.479k (± 2.2%) i/s -      7.436k in   5.028877s
                JSON      5.338k (± 2.1%) i/s -     26.772k in   5.017948s
          JSON::Pure    434.372  (± 2.5%) i/s -      2.184k in   5.031419s
                Yajl      6.534k (± 6.2%) i/s -     32.660k in   5.019365s
                  Oj     14.995k (± 5.3%) i/s -     74.776k in   5.002104s

Comparison:
                  Oj:    14994.8 i/s
                Yajl:     6533.8 i/s - 2.29x  slower
                JSON:     5337.6 i/s - 2.81x  slower
               JsonW:     1479.4 i/s - 10.14x  slower
          JSON::Pure:      434.4 i/s - 34.52x  slower
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/R167/jsonw. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JsonW project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/R167/jsonw/blob/master/CODE_OF_CONDUCT.md).

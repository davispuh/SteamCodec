# SteamCodec
[![Gem Version](https://badge.fury.io/rb/steam_codec.png)](http://badge.fury.io/rb/steam_codec)

SteamCodec is a library for working with different [Steam client](http://store.steampowered.com/about/) (and [Source engine](http://source.valvesoftware.com/)) file formats.

Currently supported formats:

* [KeyValues](https://developer.valvesoftware.com/wiki/KeyValues)
* VDF (Valve Data Format)
* ACF (ApplicationCacheFile)


PKV (packed KeyValues) isn't supported yet.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'steam_codec'
```

And then execute:

```shell
bundle
```

Or install it yourself as:

```shell
gem install steam_codec
```

### Dependencies

gem `insensitive_hash`

## Usage

```ruby
require 'steam_codec'

File.open("appmanifest_220.acf") do |file|
    acf = SteamCodec::ACF::loadFromFile(file)
    puts acf.UserConfig.Name
end
```

## Documentation

YARD with markdown is used for documentation (`redcarpet` required)

## Specs

RSpec and simplecov are required, to run tests just `rake spec`
code coverage will also be generated

## Code status

[![Build Status](https://travis-ci.org/davispuh/SteamCodec.png?branch=master)](https://travis-ci.org/davispuh/SteamCodec)
[![Dependency Status](https://gemnasium.com/davispuh/SteamCodec.png)](https://gemnasium.com/davispuh/SteamCodec)
[![Coverage Status](https://coveralls.io/repos/davispuh/SteamCodec/badge.png)](https://coveralls.io/r/davispuh/SteamCodec)
[![Code Climate](https://codeclimate.com/github/davispuh/SteamCodec.png)](https://codeclimate.com/github/davispuh/SteamCodec)

## Unlicense

![Copyright-Free](http://unlicense.org/pd-icon.png)

All text, documentation, code and files in this repository are in public domain (including this text, README).
It means you can copy, modify, distribute and include in your own work/code, even for commercial purposes, all without asking permission.

[About Unlicense](http://unlicense.org/)

## Contributing

Feel free to improve anything.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


**Warning**: By sending pull request to this repository you dedicate any and all copyright interest in pull request (code files and all other) to the public domain. (files will be in public domain even if pull request doesn't get merged)

Also before sending pull request you acknowledge that you own all copyrights or have authorization to dedicate them to public domain.

If you don't want to dedicate code to public domain or if you're not allowed to (eg. you don't own required copyrights) then DON'T send pull request.


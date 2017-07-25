# AsciiDoctor-RFC

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/transcryptor`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Status

[![Build Status](https://img.shields.io/travis/riboseinc/ascii_doctor_rfc/master.svg)](https://travis-ci.org/riboseinc/ascii_doctor_rfc)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'asciidoctor_rfcxml'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install asciidoctor_rfcxml

## Usage

The gem can be used via the command line as well as from ruby command. 

The usage via the command line:

    asciidoctor_rfcxml SOURCE_FILE [options] FORMATS...


The options will be:


    -h           --help              show the help message and exit
    -n           --no-dtd            disable DTD validation step
    -N           --no-network        don't use the network to resolve references
    -q           --quiet             dont print anything
    -v           --verbose           print extra information
    -V           --version           display the version number and exit

    -b BASENAME  --basename=BASENAME specify the base name for output files
    -D DATE      --date=DATE         run as if todays date is DATE (format: yyyy-mm-dd)
    -d DTD       --dtd=DTD           specify an alternate dtd file
    -o FILENAME  --out=FILENAME      specify an output filename


    FORMATS:
    --txt
    --html

## Development

TODO: Write usage instructions here

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ascii_doctor_rfc. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

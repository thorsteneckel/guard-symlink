# Guard::Symlink

Symlink guard allows you automatically link all files from watched folders to your execution folder. Folder paths get created and removed automatically if needed.

## Installation

Please be sure to have [Guard](https://github.com/guard/guard) installed before continue.

Install the gem:

`gem install guard-symlink`

Add it to your Gemfile (inside test group):

`gem 'guard-symlink'`

Add guard definition to your Guardfile by running this command:

`guard init symlink`

## Usage

`bundle exec guard -w /workspace/link_to_current/ /workspace/anotherone/`

## Options

Available options:

* :cmd - an Array of files that should get ignored.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thorsteneckel/guard-symlink. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


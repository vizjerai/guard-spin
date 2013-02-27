Guard::Spin
===========

Guard::Spin automatically starts and stops [Spin](https://github.com/jstorimer/spin) server.

Install
-------

Please be sure to have [Guard](https://github.com/guard/guard) installed before continue.

Install the gem:

    $ gem install guard-spin

Add it to your Gemfile (inside development group):

``` ruby
gem 'guard-spin'
```

Add guard definition to your Guardfile by running this command:

    $ guard init spin

Usage
-----

Please read [Guard usage doc](https://github.com/guard/guard#readme)

Guardfile
---------

Please read [Guard doc](https://github.com/guard/guard#readme) for more information about the Guardfile DSL.

### Options

Available options:

``` ruby
:rspec => false          # Don't use RSpec
:test_unit => false      # Don't use Test::Unit
:bundler => false        # Don't use "bundle exec"
:cli => '--time'         # Pass options to spin serve. `spin -h` for more spin options
:spec_paths => ["spec"]  # specify an array of paths that contain spec files
:run_all => true         # Run all tests when hitting enter in guard
```

Development
-----------

* Source hosted at [GitHub](https://github.com/vizjerai/guard-spin)
* Report issues/Questions/Feature requests on [GitHub Issues](https://github.com/vizjerai/guard-spin/issues)

Pull requests are very welcome! Make sure your patches are well tested. Please create a topic branch for every separate change
you make.

Authors
------

* [Jonathan](https://github.com/jonsgreen)
* [Andrew Assarattanakul](https://github.com/vizjerai)

Many Thanks To
--------------

* [Jesse Storimer](https://github.com/jstorimer)

[![CircleCI](https://circleci.com/gh/hashrocket/capybara-webmock.svg?style=svg)](https://circleci.com/gh/hashrocket/capybara-webmock)
[![Version](https://img.shields.io/gem/v/capybara-webmock.svg?style=flat)](https://rubygems.org/gems/capybara-webmock)

# Capybara::Webmock

Browser integration tests are expensive. We can mock external requests in our
tests, but once a browser is involved, we lose control.

External JavaScript libraries, CDN's, images, analytics, and more can slow an
integration test suite to a crawl.

`Capybara::Webmock` is a Rack proxy server that sits between your Ruby on Rails
Selenium Firefox test suite and the Internet, blocking external requests.

Adding this gem to your project can significantly speed up the test suite. No
more waiting on irrelevant external requests.

`localhost` and `lvh.me` are the only whitelisted domains. Custom domain
support is a planned feature.

This gem currently supports Ruby on Rails applications with an RSpec test
suite, using the Selenium Firefox driver. ChromeDriver support is in the works.

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'capybara-webmock'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install capybara-webmock
```

### Usage

In your `spec/rails_helper.rb`, add the following:

```ruby
require 'capybara/webmock'
```

Then in your RSpec configuration:

```ruby
RSpec.configure do |config|
  config.before(:suite) do
    Capybara::Webmock.start
  end

  config.after(:suite) do
    Capybara::Webmock.stop
  end
end
```

Then use the capybara-webmock JavaScript driver:

```ruby
Capybara.javascript_driver = :capybara_webmock
```

### Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

### Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/hashrocket/capybara-webmock. This project is intended to be
a safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](http://contributor-covenant.org) code of
conduct.

### License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

---

### About

[![Hashrocket logo](https://hashrocket.com/hashrocket_logo.svg)](https://hashrocket.com)

`Capybara::Webmock` is supported by the team at [Hashrocket, a multidisciplinary
design and development consultancy](https://hashrocket.com). If you'd like to
[work with us](https://hashrocket.com/contact-us/hire-us) or [join our
team](https://hashrocket.com/contact-us/jobs), don't hesitate to get in touch.

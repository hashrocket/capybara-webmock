[![CircleCI](https://img.shields.io/circleci/project/hashrocket/capybara-webmock/master.svg?maxAge=2592000)](https://circleci.com/gh/hashrocket/capybara-webmock)
[![Version](https://img.shields.io/gem/v/capybara-webmock.svg?style=flat)](https://rubygems.org/gems/capybara-webmock)

# Capybara::Webmock

> Mock external requests for Capybara JavaScript drivers.

Browser integration tests are expensive. We can mock external requests in our
tests, but once a browser is involved, we lose control.

External JavaScript libraries, CDN's, images, analytics, and more can slow an
integration test suite to a crawl.

`Capybara::Webmock` is a Rack proxy server that sits between your Ruby on Rails
Selenium test suite and the Internet, blocking external requests.

Use of this gem can significantly speed up the test suite. No more waiting on
irrelevant external requests.

`localhost`, `127.0.0.1`, `*.lvh.me`, and `lvh.me` are the only whitelisted
domains. Custom domain support is a planned feature.

This gem currently supports Ruby on Rails applications
using the Selenium Firefox and Chrome drivers.

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
# spec/spec_helper.rb

RSpec.configure do |config|
  config.before(:each) do |example|
    if example.metadata[:type] == :feature
      Capybara::Webmock.start
    end
  end

  config.after(:suite) do
    Capybara::Webmock.stop
  end
end
```

Then use the `capybara_webmock` JavaScript driver:

```ruby
# Use Firefox Driver
Capybara.javascript_driver = :capybara_webmock
```

or:

```ruby
# Use Chrome Driver
Capybara.javascript_driver = :capybara_webmock_chrome
```

```ruby
# Use Poltergeist Driver
Capybara.javascript_driver = :capybara_webmock_poltergeist
```

*NOTE: These are just two default driver wrappers this gem provides. If you are
already using a custom driver profile you can still use `capybara-webmock`, you
just need to configure proxy settings to `127.0.0.1:9292`*

By default the proxy server runs on port `9292`, but this can be customized
with the following configuration:

```ruby
Capybara::Webmock.port_number = 8080
```

During each test, you can inspect the list of proxied requests:

```ruby
it 'makes a request to /somewhere when the user visits the page' do
  visit "/some-page"
  expect(Capybara::Webmock.proxied_requests.any?{|req| req.path == "/somewhere" }).to be
end
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

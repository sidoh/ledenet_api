# ledenet_api
An API for the [LEDENET Magic UFO LED WiFi Controller](http://amzn.com/B00MDKOSN0)

## What's this?
This RGB LED controller is a relatively cheap (~$30) alternative to something like the Phillips Hue RGB Strip + Hub, which can run you between $100 and $200. 

However, it doesn't come with an open API, and doesn't integrate with smarthome hubs (SmartThings, etc.). I used a [packet capture app](https://play.google.com/store/apps/details?id=app.greyshirts.sslcapture&hl=en) on my phone to reverse engineer how the official app communicated with the controller.

## Installing

ledenet_api is available on [Rubygems](https://rubygems.org). You can install it with:

```
$ gem install ledenet_api
```

You can also add it to your Gemfile:

```
gem 'ledenet_api'
```

## Using it

### Device discovery

These devices implement a service discovery protocol, which allows you to find them on your network without digging for their IP address. To use it:

```ruby
require 'ledenet_api'
devices = LEDENET.discover_devices
=> [#<LEDENET::Device:0x007feccc0241d8 @ip="10.133.8.113", @hw_addr="XXXXXXXXXXXX", @model="HF-LPB100-ZJ200">]
devices.first.ip
=> "10.133.8.113"
```

By deafult, `discover_devices` waits for up to 5 seconds for a single device to respond, and returns immediately after finding one. To change this behavior:

```ruby
irb(main):005:0> LEDENET.discover_devices(expected_devices: 2, timeout: 1)
=> [#<LEDENET::Device:0x007fff328f4330 @ip="10.133.8.113", @hw_addr="XXXXXXXXXXXX", @model="HF-LPB100-ZJ200">]
```

### API

To construct an API class, use the following:

```ruby
api = LEDENET::Api.new('10.133.8.113')
```

By default, each API call will open a new connection, and close it when it's finished. This is convenient if the API is being used inside of a long-running process (like a web server). If what you're doing is more short-lived, you can reuse the same connection:

```ruby
api = LEDENET::Api.new('10.133.8.113', reuse_connection: true)
```

By default, the API will re-try transient-looking failures three times. You can change this behavior with:

```ruby
api = LEDENET::Api.new('10.133.8.113', reuse_connection: true, max_retries: 0)
```

### Status

To check if the controller is currently on:

```ruby
api.on?
=> false
```

To turn the controller on and off:

```ruby
api.on
=> true
api.off
=> true
```

### Color

To get the current color setting (as an array of RGB values):

```ruby
api.current_color
=> [10, 10, 10]
```

To set the color:

```ruby
irb(main):016:0> api.update_color(255, 0, 255)
=> true
```

### Warm White

This controller is also capable of controling Warm White (WW) LEDs. I didn't have a strip to test, but I'm pretty sure I found out how to control it. If this would be useful to you, please open an issue/pull request.

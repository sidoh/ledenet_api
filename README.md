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

In addition to the Ruby API, this gem also comes bundled with an executable named `ledenet-ufo`.

### Commandline

Here's the `--help` message:

```
$ ledenet-ufo
  Usage: ledenet-ufo --list
     OR: ledenet-ufo [IP|HW ADDR] [OPTIONS]

    -r, --red [VALUE]                Set red to VALUE
    -g, --green [VALUE]              Set green to VALUE
    -b, --blue [VALUE]               Set blue to VALUE
    -w, --warm-white [VALUE]         Set warm white to VALUE
        --on                         Turn on the controller
        --off                        Turn off the controller
    -l, --list                       Prints a list of available devices and exits
    -s, --status                     Prints status as JSON
    -h, --help                       Prints this help message
        --function-id [VALUE]        Set function id to VALUE
    -f, --function [VALUE]           Set function to VALUE.
```

When using it, you can specify the IP address, hardware (mac) address, or let `ledenet_api` choose an arbitrary device on the local network (this would work well if you only have one).

Examples:

#### List available devices

```
$ ledenet-ufo --list
      IP ADDRESS         HW ADDRESS              Model #
    10.133.8.113       XXXXXXXXXXXX      HF-LPB100-ZJ200
```

#### Get current status

```
$ ledenet-ufo -s
{"red":"255","green":"255","blue":"255","warm_white":"255","is_on":true}
```

#### Turn on, adjust colors

```
$ ledenet-ufo --on -r 200 -g 0 -b 255 --warm-white 0 --status
{"red":"200","green":"0","blue":"255","warm_white":"255","is_on":true}
```

#### Turn off

```
$ ledenet-ufo --off
```

#### Set function

```
$ ledenet-ufo --function seven_color_cross_fade --speed 10
```

### Ruby API

#### Device discovery

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

#### API

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

#### Status

To check if the controller is currently on:

```ruby
api.on?
=> false
```

To turn the controller on and off:

```ruby
api.on
api.off
```

#### Color / Warm White

To get the current color settings:

```ruby
api.current_color_data
#=> {:red=>255, :green=>255, :blue=>255, :warm_white=>255}
api.current_rgb
#=> [255, 255, 255]
api.current_warm_white
#=> 255
```

To set the color:

```ruby
api.update_rgb(255, 0, 255)

api.update_warm_white(100)
```

You can also update individual parameters:

```ruby
api.update_color_data(red: 100)

api.update_color_data(blue: 255, warm_white: 0)
```

#### Functions

The UFO devices ship with 20 pre-programmed lighting functions. ledenet_api has support for these:

```ruby
LEDENET::Functions.all_functions
#=> [:SEVEN_COLOR_CROSS_FADE, :RED_GRADUAL_CHANGE, :GREEN_GRADUAL_CHANGE, :BLUE_GRADUAL_CHANGE, :YELLOW_GRADUAL_CHANGE, :CYAN_GRADUAL_CHANGE, :PURPLE_GRADUAL_CHANGE, :WHITE_GRADUAL_CHANGE, :RED_GREEN_CROSS_FADE, :RED_BLUE_CROSS_FADE, :SEVEN_COLOR_STROBE_FLASH, :RED_STROBE_FLASH, :GREEN_STROBE_FLASH, :BLUE_STROBE_FLASH, :YELLOW_STROBE_FLASH, :CYAN_STROBE_FLASH, :PURPLE_STROBE_FLASH, :WHITE_STROBE_FLASH, :SEVEN_COLOR_JUMPING_CHANGE, :GREEN_BLUE_CROSS_FADE]
```

```ruby
fn = LEDENET::Functions::SEVEN_COLOR_CROSS_FADE
speed = 0 # very slow

api.update_function(fn, speed)

api.update_function(:blue_green_cross_fade, 100) # Very fast
```

To quit the function and return to a constant color, simply update a color value:

```ruby
api.update_color_data(warm_white: 255)
```

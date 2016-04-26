# CentrifugeiOS

[![Build Status](https://travis-ci.org/mogol/centrifuge-ios.svg?branch=develop)](https://travis-ci.org/mogol/centrifuge-ios)
[![Version](https://img.shields.io/cocoapods/v/CentrifugeiOS.svg?style=flat)](http://cocoapods.org/pods/CentrifugeiOS)
[![License](https://img.shields.io/cocoapods/l/CentrifugeiOS.svg?style=flat)](http://cocoapods.org/pods/CentrifugeiOS)
[![Platform](https://img.shields.io/cocoapods/p/CentrifugeiOS.svg?style=flat)](http://cocoapods.org/pods/CentrifugeiOS)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. You could chat with [here](http://jsfiddle.net/FZambia/yG7Uw/) and command from [Centrifugal web](https://Centrifuge.herokuapp.com/)

## Usage

Create client: 

```swift
let timestamp = "\(Int(NSDate().timeIntervalSince1970))"

let creds = CentrifugeCredentials(secret: secret, user: user, timestamp: timestamp)
let url = "wss://Centrifuge.herokuapp.com/connection/websocket"
client = Centrifuge.client(url, creds: creds, delegate: self)
```
Connect to server:
```swift
client.connect { message, error in }
```
Subscribe to channel:
```swift
client.subscribe(channel, delegate: delegate) { message, error in }
```
Publish: 
```swift
client.publish(channel, data:  data) { message, error in }
```

See the example project and [docs](https://fzambia.gitbooks.io/centrifugal/content/server/client_protocol.html) for more information.

## Requirements

Swift 2.2
iOS 8.0+

## Installation

Not ready.
~~CentrifugeiOS is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:~~

```ruby
pod "CentrifugeiOS"
```

## Author

Herman Saprykin, saprykin.h@gmail.com

## License

CentrifugeiOS is available under the MIT license. See the LICENSE file for more info.

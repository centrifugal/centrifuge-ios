# CentrifugeiOS

[![Build Status](https://travis-ci.org/centrifugal/centrifuge-ios.svg?branch=develop)](https://travis-ci.org/centrifugal/centrifuge-ios)
[![Version](https://img.shields.io/cocoapods/v/CentrifugeiOS.svg?style=flat)](http://cocoapods.org/pods/CentrifugeiOS)
[![License](https://img.shields.io/cocoapods/l/CentrifugeiOS.svg?style=flat)](http://cocoapods.org/pods/CentrifugeiOS)
[![Platform](https://img.shields.io/cocoapods/p/CentrifugeiOS.svg?style=flat)](http://cocoapods.org/pods/CentrifugeiOS)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. You could chat with [here](http://jsfiddle.net/FZambia/yG7Uw/) and command from [Centrifugal web](https://centrifugo.herokuapp.com/)

## Usage

Create client: 

```swift
let timestamp = "\(Int(Date().timeIntervalSince1970))"
let token =  Centrifuge.createToken(string: "\(user)\(timestamp)", key: secret)
        
let creds = CentrifugeCredentials(token: token, user: user, timestamp: timestamp)
let url = "wss://centrifugo.herokuapp.com/connection/websocket"
client = Centrifuge.client(url: url, creds: creds, delegate: self)

```
Connect to server:
```swift
client.connect { message, error in }
```
Subscribe to channel:
```swift
client.subscribe(toChannel: channel, delegate: delegate) { message, error in }
```
Publish: 
```swift
client.publish(toChannel: channel, data:  data) { message, error in }
```

See the example project and [docs](https://fzambia.gitbooks.io/centrifugal/content/server/client_protocol.html) for more information.

## Requirements

* Version 0.1.0: Swift 2.2, iOS 8.0+
* Version 1.0.0: Swift 2.3, iOS 8.0+, Xcode 7
* Version 2.0.0: Swift 2.3, iOS 9.3+, Xcode 8
* Version 3.0.0: Swift 3.0, iOS 9.3+, Xcode 8
* Version 4.0.0: Swift 4.0, iOS 9.3+, Xcode 9
* Version 5.0.0: Swift 4.0, iOS 9.3+, Xcode 9

## Installation

### CocoaPods

CentrifugeiOS is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CentrifugeiOS"
```

### Carthage

Add the following to your Cartfile:

```
github "centrifugal/centrifuge-ios"
```
Then run `carthage update`.

## Author

German Saprykin, saprykin.h@gmail.com

## License

CentrifugeiOS is available under the MIT license. See the LICENSE file for more info.

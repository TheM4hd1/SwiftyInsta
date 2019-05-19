![Logo](https://github.com/mgp25/Instagram-API/raw/master/examples/assets/instagram.png) 
## About Instagram APIs

Instagram offers two kind of APIs for developers. The [Official API](https://www.instagram.com/developer/) and **[Unofficial API](https://github.com/TheM4hd1/SwiftyInsta/blob/master/SwiftyInsta/API/Constants/URLs.swift)**.

They both have pros and cons, **the private api is a tokenless api** which means it doesn't require any token or app registration in Instagram system.<br></br>
But you should know that its not authorized, maintained, sponsored or endorsed by Instagram.

## SwiftyInsta, Tokenless Instagram API

SwiftyInsta allows you to build your own customized Instagram client or Bot. It is 100% open for all developers who wish to create applications on Instagram platform.

This project is still in development phase and intends to provide all features which are available in the Official API.

## Installation

### CocoaPods
[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:
```terminal
$ gem install cocoapods
```
To integrate SwiftyInsta into your Xcode project using CocoaPods, specify it to a target in your Podfile:
```text
pod 'SwiftyInsta'
```
Then, run the following command:
```terminal
$ pod install
````

### Manual
To use this library in your project manually you may:
    - Add compiled framework from ```General > Linked frameworks and libraries```
    - Clone the project, right click on your root project(not SwiftyInsta) and select ```Add files...```, then select the ```SwiftyInsta.xcodeproj```. after that go to your ```project>embeded libraries``` and select ```SwiftyInsta.framework```, build the project and import ```SwiftyInsta```

## Usage

### Create API Handler Instance
```swift
import SwiftyInsta

let _urlSession = URLSession(configuration: .default)
let handler = try! APIBuilder()
.createBuilder()
.setHttpHandler(urlSession: _urlSession)
.setRequestDelay(delay: .default)
.setUser(user: user)
.build()
```

### Login

```swift
try? handler.login { (result) in
    //result: Result<LoginResultModel>
}
```

aslo to prevent known login issues, you can use [Siwa](https://github.com/TheM4hd1/Siwa), a helper framework for SwiftyInsta
#### Search User
```swift
try? handler.getUser(username: "username", completion: { (result) in
    //result: (Result<UserModel>)
})
```
## Documentation

- See [Features](https://github.com/TheM4hd1/SwiftyInsta/wiki/Features) for all available APIs
- See [Usage](https://github.com/TheM4hd1/SwiftyInsta/wiki/Usage) for more specific usage and use case documentation
- See [Tests](https://github.com/TheM4hd1/SwiftyInsta/tree/master/SwiftyInstaTests) for some real world examples

## Contributions

Pull requests and issues are welcome

## License

SwiftyInsta is licensed under the MIT license. See [LICENSE](https://github.com/TheM4hd1/SwiftyInsta/blob/master/LICENSE) for more info.

## Thanks to

[mpg25](https://github.com/mgp25/Instagram-API)

[a-legotin](https://github.com/a-legotin/InstaSharper)

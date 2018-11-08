<p align="center">
  <img width="200" height="200" src="https://raw.githubusercontent.com/TheM4hd1/SwiftyInsta/master/Screenshots/Logo.png">
</p>

**SwiftyInsta** makes it easy to deal with **Instagram** trough a **tokenless private api**.
You can get/post account information, media, explore tags, user feed comments and ...
## Overview
This project intends to provide all the features available in the Instagram API. It is being developed in Swift 4.2 and Xcode 10.1 (10B61)

#### This repository is provided for reference purposes only.

* Please note that this project is still in design and development phase; the libraries may suffer major changes, so don't rely (yet) in this software for production uses. *

* Before posting new issues: [Test Project](https://github.com/TheM4hd1/SwiftyInsta/tree/master/SwiftyInstaTests)

### Integration
To use this library in your project manually you may:

1. compile framework and add it to project
2. for Workspaces, include the whole SwiftyInsta.xcodeproj

## Features

Currently the library supports following coverage of the following Instagram APIs:

***

- [x] Login
- [x] Logout
- [x] Get User Info By Username
- [x] Get Current User Info
- [x] Get Followings By Username
- [x] Get Followers By Username
- [x] Get User Explore Feed

## Usage

#### Initialization

```swift
import SwiftyInsta
```

#### Use builder to get Insta API instance:

```swift
let handler = try! APIBuilder()
                    .createBuilder()
                    .setHttpHandler(config: .default)
                    .setRequestDelay(delay: .default)
                    .setUser(user: user)
                    .build()
```

#### Login
```swift
try? handler.login { (result) in
    // result: Result<LoginResultModel>
}
```

#### Logout
```swift
try? handler.logout { (result) in
    // result: Result<Bool>
}
```

#### Get User
```swift
try? handler.getUser(username: "username", completion: { (result) in
   // result: (Result<UserModel>)
})
```

#### Get Followers
```swift
// searchQuery: search for specific username
// paginationParameter: number of pages to read followers from.
try handler.getUserFollowers(username: "", paginationParameter: PaginationParameters.maxPagesToLoad(maxPages: 15), searchQuery: "", completion: { (result) in
    // result: Result<[UserShortModel]>
})
```

## Special thanks

[a-legotin](https://github.com/a-legotin) and his [InstaSharper](https://github.com/a-legotin/InstaSharper)

## Legal

This code is in no way affiliated with, authorized, maintained, sponsored or endorsed by Instagram or any of its affiliates or subsidiaries. This is an independent and unofficial API wrapper.

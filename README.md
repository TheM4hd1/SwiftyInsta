<p align="center">
<img width="200" height="200" src="https://raw.githubusercontent.com/TheM4hd1/SwiftyInsta/master/Screenshots/Logo.png">
</p>

## Overview
Tokenless Instagram's private API.

This project intends to provide all the features available in the Instagram API including media upload, direct messaging, stories and more.

* Please note that this project is still in design and development phase, the libraries may suffer major changes, so don't rely (yet) in this software for production uses.

* It is being developed in Swift 4.2 and Xcode 10.1 (10B61)

### Integration
To use this library in your project manually you may:

1. compile framework and add it to project
2. for Workspaces, include the whole SwiftyInsta.xcodeproj

## Features

Currently the library supports following coverage of the following Instagram APIs:

***

- [x] Login
- [x] Logout
- [x] Get user information (by username)
- [x] Get user information (by id)
- [x] Get current user Information
- [x] Get user followings 
- [x] Get user followers
- [x] Get user explore feed
- [x] Get user timeline medias
- [x] Get user feed medias
- [x] Get media by ID
- [x] Explore tags by tag name
- [x] Get your recent activities
- [x] Get recent following activities
- [x] Get direct inbox
- [x] Send direct message to users and groups
- [x] Get direct thread by thread id
- [x] Get recent recipients
- [x] Get ranked recipients
- [x] Change account privacy to public/private
- [x] Change password
- [x] Like/Unlike media
- [x] Get comments of specific media
- [x] Follow/UnFollow user
- [x] Get friendship status
- [x] Block/Unblock user
- [x] Get user tags
- [x] Upload Photo
- [x] Upload Photo Album
- [x] Add/Remove comment
- [x] Delete Media (photo/video)

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

## TODO
Currently the library suffers from nested asynchronous functions (Pyramid of Doom), the next step is *Optimizing Library*
- [ ] Writing Cleaner Asynchronous Code Using Promise Pattern

## Special thanks

[a-legotin](https://github.com/a-legotin) and his [InstaSharper](https://github.com/a-legotin/InstaSharper)

## Legal

This code is in no way affiliated with, authorized, maintained, sponsored or endorsed by Instagram or any of its affiliates or subsidiaries. This is an independent and unofficial API wrapper.

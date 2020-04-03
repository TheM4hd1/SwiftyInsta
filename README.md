# SwiftyInsta
[![CI Status](https://img.shields.io/travis/TheM4hd1/SwiftyInsta/master.svg?style=flat)](https://travis-ci.org/TheM4hd1/SwiftyInsta)
[![Version](https://img.shields.io/cocoapods/v/SwiftyInsta.svg?style=flat)](https://cocoapods.org/pods/SwiftyInsta)
[![License](https://img.shields.io/cocoapods/l/SwiftyInsta.svg?style=flat)](https://github.com/TheM4hd1/SwiftyInsta/LICENSE.md)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyInsta.svg?style=flat)](https://cocoapods.org/pods/SwiftyInsta)
<img src="https://img.shields.io/badge/supports-CocoaPods%2C%20Swift%20Package%20Manager-ff69b4.svg">

**Instagram** offers two kinds of APIs to developers. The [Instagram API Platform](https://www.instagram.com/developer/) (extremely limited in functionality and close to being discontinued), and the [Instagram Graph API](https://developers.facebook.com/docs/instagram-api) for _Business_ and _Creator_ accounts only.

However, **Instagram** apps rely on a third type of _API_, the so-called **Private API** or _Unofficial API_, and [SwiftyInsta](https://github.com/TheM4hd1/SwiftyInsta) is an **iOS, macOS, tvOS and watchOS client** for them, written entirely in **Swift**.
You can try and create a better Instagram experience for your users, or write bots for automating different tasks.

These _Private API_ require no _token_ or _app registration_ but they're not _authorized_ by Instagram for external use.
Use this at your own risk.

## Installation
### Swift Package Manager (Xcode 11 and above)
1. Select `File`/`Swift Packages`/`Add Package Dependency…` from the menu.
1. Paste `https://github.com/TheM4hd1/SwiftyInsta.git`.
1. Follow the steps.

### CocoaPods
[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:
```terminal
$ gem install cocoapods
```
To integrate **SwiftyInsta** into your Xcode project using CocoaPods, specify it in your `Podfile`:
```text
use_frameworks!

target '<Your Target Name>' do
    pod 'SwiftyInsta', '~> 2.0'
end
```
Then, run the following command:
```terminal
$ pod install
````

**SwiftyInsta** depends on [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift)<!--[GzipSwift](https://github.com/1024jp/GzipSwift),--> and [keychain-swift](https://github.com/evgenyneu/keychain-swift).

<!--
### Manually
To use this library in your project manually you may:
    - Add compiled framework from ```General > Linked frameworks and libraries```
    - Clone the project, right click on your root project(not SwiftyInsta) and select ```Add files...```, then select the ```SwiftyInsta.xcodeproj```. after that go to your ```project>embeded libraries``` and select ```SwiftyInsta.framework```, build the project and import ```SwiftyInsta```
-->

## Login
### `Credentials`
```swift
// these need to be strong references.
self.credentials = Credentials(username: /* username */, password: /* password */, verifyBy: .text)
self.handler = APIHandler()
handler.authenticate(with: .user(credentials)) {
    switch $0 {
    case .success(let response, _):
        print("Login successful.")
        // persist cache safely in the keychain for logging in again in the future.
        guard let key = response.persist() else { return print("`Authentication.Response` could not be persisted.") }
        // store the `key` wherever you want, so you can access the `Authentication.Response` later.
        // `UserDefaults` is just an example.
        UserDefaults.standard.set(key, forKey: "current.account")
        UserDefaults.standard.synchronize()
    case .failure(let error):
        if error.requiresInstagramCode {
            /* update interface to ask for code */
        } else {
            /* notify the user */
        }
    }
}
```

Once the user has typed the two factor authentication code or challenge code, you simply do
```swift
self.credentials.code = /* the code */
```
And the `completionHandler` in the previous `authenticate(with: completionHandler:)` will automatically catch the response.


### `LoginWebViewController` (>= iOS 12 only)
```swift
let login = LoginWebViewController { controller, result in
    controller.dismiss(animated: true, completion: nil)
    // deal with authentication response.
    guard let (response, _) = try? result.get() else { return print("Login failed.") }
    print("Login successful.")
    // persist cache safely in the keychain for logging in again in the future.
    guard let key = response.persist() else { return print("`Authentication.Response` could not be persisted.") }
    // store the `key` wherever you want, so you can access the `Authentication.Response` later.
    // `UserDefaults` is just an example.
    UserDefaults.standard.set(key, forKey: "current.account")
    UserDefaults.standard.synchronize()
}
if #available(iOS 13, *) {
    present(login, animated: true, completion: nil) // just swipe down to dismiss.
} else {
    present(UINavigationController(rootViewController: login),  // already adds a `Cancel` button to dismiss it.
            animated: true,
            completion: nil)
}
```
Or implement your own custom `UIViewController` using `LoginWebView`, and pass it to an `APIHandler` `authenticate` method using `.webView(/* your login web view */)`.

### `Authentication.Response`
If you've already persisted a user's `Authentication.Response`:

```swift
// recover the `key` returned by `Authentication.Response.persist()`.
// in our example, we stored it in `UserDefaults`.
guard let key = UserDefaults.standard.string(forKey: "current.account") else { return print("`key` not found.") }
// recover the safely persisted `Authentication.Response`.
guard let cache = Authentication.Response.persisted(with: key) else { return print("`Authentication.Response` not found.") }
// log in.
let handler = APIHandler()
handler.authenticate(with: .cache(cache)) { _ in
    /* do something here */
}
```

## Usage
All endpoints are easily accessible from your `APIHandler` instance.

```swift
let handler: APIHandler = /* a valid, authenticated handler */
// for instance you can…
// …fetch your inbox.
handler.messages.inbox(with: .init(maxPagesToLoad: .max),
                       updateHandler: nil,
                       completionHandler: { _, _ in /* do something */ })
// …fetch all your followers.
handler.users.following(user: .me,
                        with: .init(maxPagesToLoad: .max),
                        updateHandler: nil,
                        completionHandler: { _, _ in /* do something */ })
```

Futhermore, responses now display every single value contained in the `JSON` file returned by the **API**: just access any `ParsedResponse` `rawResponse` and start browsing, or stick with the suggested accessories (e.g. `User`'s `username`, `name`, etc. and `Media`'s `aspectRatio`, `takenAt`, `content`, etc.).

## Contributions

_Pull requests_ and _issues_ are more than welcome.

[![](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/images/0)](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/links/0)[![](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/images/1)](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/links/1)[![](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/images/2)](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/links/2)[![](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/images/3)](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/links/3)[![](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/images/4)](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/links/4)[![](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/images/5)](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/links/5)[![](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/images/6)](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/links/6)[![](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/images/7)](https://sourcerer.io/fame/TheM4hd1/TheM4hd1/SwiftyInsta/links/7)

## License

**SwiftyInsta** is licensed under the MIT license. See [LICENSE](https://github.com/TheM4hd1/SwiftyInsta/blob/master/LICENSE) for more info.

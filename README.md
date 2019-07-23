# SwiftyInsta
[![CI Status](https://img.shields.io/travis/TheM4hd1/SwiftyInsta.svg?style=flat)](https://travis-ci.org/TheM4hd1/SwiftyInsta)
[![Version](https://img.shields.io/cocoapods/v/SwiftyInsta.svg?style=flat)](https://cocoapods.org/pods/SwiftyInsta)
[![License](https://img.shields.io/cocoapods/l/SwiftyInsta.svg?style=flat)](https://cocoapods.org/pods/SwiftyInsta)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyInsta.svg?style=flat)](https://cocoapods.org/pods/SwiftyInsta)

**Instagram** offers two kinds of APIs to developers. The [Instagram API Platform](https://www.instagram.com/developer/) (extremely limited in functionality and close to being discontinued), and the [Instagram Graph API](https://developers.facebook.com/docs/instagram-api) for _Business_ and _Creator_ accounts only.

However, **Instagram** apps rely on a third type of _API_, the so-called **Private API** or _Unofficial API_, and [SwiftyInsta](https://github.com/TheM4hd1/SwiftyInsta) is an **iOS client** for them, written entirely in **Swift**.
You can try and create a better Instagram experience for your users, or write bots for automatic different tasks.

These _Private API_ require no _token_ or _app registration_ but they're not _authorized_ by Instagram for external use.
Use this at your own risk.

## Installation
### CocoaPods
[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:
```terminal
$ gem install cocoapods
```
To integrate SwiftyInsta into your Xcode project using CocoaPods, specify it in your `Podfile`:
```text
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'SwiftyInsta', '~> 2.0'
end
```
Then, run the following command:
```terminal
$ pod install
````

<!--
### Manually
To use this library in your project manually you may:
    - Add compiled framework from ```General > Linked frameworks and libraries```
    - Clone the project, right click on your root project(not SwiftyInsta) and select ```Add files...```, then select the ```SwiftyInsta.xcodeproj```. after that go to your ```project>embeded libraries``` and select ```SwiftyInsta.framework```, build the project and import ```SwiftyInsta```
-->

## Login

### `LoginWebView` (> iOS 11)
```swift
import UIKit
import SwiftyInsta

@available(iOS 11, *)
class LoginViewController: UIViewController {
    /// The web view used for logging in.
    lazy var webView = LoginWebView(frame: view.bounds,
                                    didReachEndOfLoginFlow: {
                                        /* remove the web view from the view hierarchy and notify the user */
    })
    /// The endpoints handler. Use `.init(with: APIHandler.Settings)` to customize it.
    lazy var handler = APIHandler()

    override func viewDidLoad() {
        super.viewDidLoad()

        // remember to add the web view to the view hierarchy
        // before you try to authenticate.
        view.addSubview(webView)
        // prepare handler.
        handler.authenticate(with: .webView(webView)) {
            guard let (response, _) = try? $0.get() else { return print("Login failed.") }
            print("Login successful.")
            // persist cache safely in the keychain for logging in again in the future.
            guard let key = response.persist() else { return print("`SessionCache` could not be persisted.") }
            // store the `key` wherever you want, so you can access the `SessionCache` later.
            // `UserDefaults` is just an example.
            UserDefaults.standard.set(key, forKey: "current.account")
            UserDefaults.standard.synchronize()
        }
    }
}
```

### `SessionCache` (+ `Siwa`)
If you've already persisted a user's `SessionCache`:

```swift
// recover the `key` returned by `Login.Response.persist()`.
// in our example, we stored it in `UserDefaults`.
guard let key = UserDefaults.standard.string(forKey: "current.account") else { return print("`key` not found.") }
// recover the safely persisted `SessionCache`.
guard let cache = SessionCache.persisted(with: key) else { return print("`SessionCache` not found.") }
// log in.
let handler = APIHandler()
handler.authenticate(with: .cache(cache)) { _ in
    /* do something here */
}
```

If you don't want to use `LoginWebView` or you need to support iOS 10.0, you can use [Siwa](https://github.com/TheM4hd1/Siwa), retrieve the `SessionCache` and pass it to the authentication method above (don't forget to `persist()` the `Login.Response`).

## Documentation

- See [Features](https://github.com/TheM4hd1/SwiftyInsta/wiki/Features) for all available APIs
- See [Usage](https://github.com/TheM4hd1/SwiftyInsta/wiki/Usage) for a more in-depth overview
- See [Tests](https://github.com/TheM4hd1/SwiftyInsta/tree/master/SwiftyInstaTests) for some real world examples

## Contributions

_Pull requests_ and _issues_ are more than welcome.

## License

**SwiftyInsta** is licensed under the MIT license. See [LICENSE](https://github.com/TheM4hd1/SwiftyInsta/blob/master/LICENSE) for more info.

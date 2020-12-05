//
//  Headers.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    private init() {}

    static let acceptLanguageKey = "Accept-Language"
    static let acceptLanguageValue = "en-US;q=1.0"
    static let xIgDeviceLocale = "X-IG-Device-Locale"
    static let xIgDeviceLocaleValue = "en-US"
    static let igCapabilitiesKey = "X-IG-Capabilities"
    static let igCapabilitiesValue = "36r/Fx8="
    static let xIgDeviceId = "X-IG-Device-ID"
    static let igConnectionTypeKey = "X-IG-Connection-Type"
    static let igConnectionTypeValue = "WIFI"
    static let xGoogleAdId = "X-Google-AD-ID"
    static let xIgAppId = "X-IG-App-ID"
    static let xIgAppIdValue = "124024574287414"
    static let userAgentKey = "User-Agent"
    // swiftlint:disable line_length
    static let userAgentValue = "Instagram 160.1.0.31.120 (\(getIdentifier()); iOS \(getOsVersion()); en_US; en-US; scale=2.00; \(getScreenSize()); 246979827) AppleWebKit/420+"
    // swiftlint:enable line_length
    static let contentTypeKey = "Content-Type"
    static let contentTypeApplicationFormValue = "application/x-www-form-urlencoded"
    static let igSignatureKey = "signed_body"
    static let igSignatureValue = "937463b5272b5d60e9d20f0f8d7d192193dd95095a3ad43725d494300a5ea5fc"
    static let igSignatureVersionKey = "ig_sig_key_version"
    static let igSignatureVersionValue = "5"
    static let timeZoneOffsetKey = "timezone_offset"
    static let timeZoneOffsetValue = "43200"
    static let countKey = "count"
    static let countValue = "1"
    static let rankTokenKey = "rank_token"
    static let bloksVersioningId = "7b2216598d8fcf84fbda65652788cb12be5aa024c4ea5e03deeb2b81a383c9e0"

    static func getIdentifier() -> String {
        #if os(iOS) && !((arch(i386)) || arch(x86_64))
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce(into: "") { (identifier, element) in
            if let value = element.value as? Int8, value != 0 {
                identifier += String(UnicodeScalar(UInt8(value)))
            }
        }
        return identifier
        #else
        return "iPhone9,1"
        #endif
    }

    static func getOsVersion() -> String {
        #if os(iOS)
        return UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
        #else
        return "13_5"
        #endif
    }

    static func getScreenSize(scale: CGFloat = 2.0) -> String {
        #if os(iOS)
        let width = Int(UIScreen.main.bounds.width * scale)
        let height = Int(UIScreen.main.bounds.height * scale)
        return String(format: "%dx%d", arguments: [width, height])
        #else
        return "750x1334"
        #endif
    }
}

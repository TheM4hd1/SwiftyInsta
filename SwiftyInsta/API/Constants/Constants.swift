//
//  Headers.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

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
    static let userAgentValue = getUserAgent()
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

    static func getUserAgent() -> String {
        #if os(iOS)
        return UserAgentHelper.generate()
        #else
        return "Instagram 160.1.0.31.120 iPhone9,1; iOS 13_5; en_US; en-US; scale=2.00; 750x1334; 246979827) AppleWebKit/420+"
        #endif
    }
}

//
//  Headers.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct Headers {

    private init() {}

    static let acceptLanguageKey = "Accept-Language"
    static let acceptLanguageValue = "en-US"
    static let igCapabilitiesKey = "X-IG-Capabilities"
    static let igCapabilitiesValue = "3brTvw=="
    static let igConnectionTypeKey = "X-IG-Connection-Type"
    static let igConnectionTypeValue = "WIFI"
    static let xGoogleAdId = "X-Google-AD-ID"
    static let userAgentKey = "User-Agent"
    static let userAgentValue = "Instagram 85.0.0.21.100 Android (21/5.0.2; 480dpi; 1080x1776; Sony; C6603; C6603; qcom; ru_RU; 146536611)"
    static let contentTypeKey = "Content-Type"
    static let contentTypeApplicationFormValue = "application/x-www-form-urlencoded"
    static let igSignatureKey = "signed_body"
    static let igSignatureValue = "937463b5272b5d60e9d20f0f8d7d192193dd95095a3ad43725d494300a5ea5fc"
    static let igSignatureVersionKey = "ig_sig_key_version"
    static let igSignatureVersionValue = "4"
    static let timeZoneOffsetKey = "timezone_offset"
    static let timeZoneOffsetValue = "43200"
    static let countKey = "count"
    static let countValue = "1"
    static let rankTokenKey = "rank_token"
}

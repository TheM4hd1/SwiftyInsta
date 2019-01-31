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
    
    static let HeaderAcceptLanguageKey = "Accept-Language"
    static let HeaderAcceptLanguageValue = "en-US"
    static let HeaderIGCapablitiesKey = "X-IG-Capabilities"
    static let HeaderIGCapablitiesValue = "3brTBw=="
    static let HeaderIGConnectionTypeKey = "X-IG-Connection-Type"
    static let HeaderIGConnectionTypeValue = "WIFI"
    static let HeaderXGoogleADID = "X-Google-AD-ID"
    static let HeaderUserAgentKey = "User-Agent"
    static let HeaderUserAgentValue = "Instagram 78.0.0.9.103 Android (21/5.0.2; 480dpi; 1080x1776; Sony; C6603; C6603; qcom; ru_RU; 95414346)"
    static let HeaderContentTypeKey = "Content-Type"
    static let HeaderContentTypeApplicationFormValue = "application/x-www-form-urlencoded"
    static let HeaderIGSignatureKey = "signed_body"
    static let HeaderIGSignatureValue = "98ff843b4c4d924311f452a965f073c7566ff680ee11d8fb7ba57264ab9fbabb"
    static let HeaderIGSignatureVersionKey = "ig_sig_key_version"
    static let HeaderIGSignatureVersionValue = "4"
    static let HeaderTimeZoneOffsetKey = "timezone_offset"
    static let HeaderTimeZoneOffsetValue = "43200"
    static let HeaderCountKey = "count"
    static let HeaderCountValue = "1"
    static let HeaderRankTokenKey = "rank_token"
}

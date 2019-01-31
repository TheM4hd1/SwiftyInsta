//
//  TwoFactorLoginInfoModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/29/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct TwoFactorLoginInfoModel: Codable {
    public var obfuscatedPhoneNumber: String
    public var showMessengerCodeOption: Bool
    public var totpTwoFactorOn: Bool
    public var smsTwoFactorOn: Bool
    public var twoFactorIdentifier: String
    public var username: String
    public var phoneVerificationSettings: PhoneVerificationSettingsModel
    
    public init(obfuscatedPhoneNumber: String, showMessengerCodeOption: Bool, totpTwoFactorOn: Bool, smsTwoFactorOn: Bool, twoFactorIdentifier: String, username: String, phoneVerificationSettings: PhoneVerificationSettingsModel) {
        self.obfuscatedPhoneNumber = obfuscatedPhoneNumber
        self.showMessengerCodeOption = showMessengerCodeOption
        self.totpTwoFactorOn = totpTwoFactorOn
        self.smsTwoFactorOn = smsTwoFactorOn
        self.twoFactorIdentifier = twoFactorIdentifier
        self.username = username
        self.phoneVerificationSettings = phoneVerificationSettings
    }
    
    static func empty() -> TwoFactorLoginInfoModel {
        return TwoFactorLoginInfoModel(
            obfuscatedPhoneNumber: "0",
            showMessengerCodeOption: false,
            totpTwoFactorOn: false,
            smsTwoFactorOn: false,
            twoFactorIdentifier: "",
            username: "",
            phoneVerificationSettings: PhoneVerificationSettingsModel.empty()
        )
    }
}

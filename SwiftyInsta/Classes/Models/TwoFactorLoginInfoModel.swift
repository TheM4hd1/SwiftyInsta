//
//  TwoFactorLoginInfoModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/29/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct TwoFactorLoginInfoModel: Codable {
    var obfuscatedPhoneNumber: Int
    var showMessengerCodeOption: Bool
    var twoFactorIdentifier: String
    var username: String
    var phoneVerificationSettings: PhoneVerificationSettingsModel
    
    static func empty() -> TwoFactorLoginInfoModel {
        return TwoFactorLoginInfoModel(
            obfuscatedPhoneNumber: 0,
            showMessengerCodeOption: false,
            twoFactorIdentifier: "",
            username: "",
            phoneVerificationSettings: PhoneVerificationSettingsModel.empty()
        )
    }
}

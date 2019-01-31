//
//  TwoFactorEnums.swift
//  SwiftyInsta
//
//  Created by Mahdi on 1/31/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public enum TwoFactorVerificationMethodsEnum: String {
    case none = "0"
    case sms = "1"
    case backup = "2"
    case totp = "3"
}

public enum TwoFactorLoginErrorTypeEnum: String {
    case invalidCode = "sms_code_validation_code_invalid"
    case missingCode = "sms_code_validation_code_missing"
}

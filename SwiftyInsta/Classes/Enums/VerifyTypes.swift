//
//  VerifyTypes.swift
//  SwiftyInsta
//
//  Created by Mahdi on 12/1/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public enum VerifyTypes: String {
    case email = "1"
    case sms = "0"
}

public enum VerifyResponse {
    case codeSent
    case badChoice
}

//
//  ChallengeModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/29/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct ChallengeModel: Codable {
    var url: String
    var apiPath: String
    var hideWebviewHeader: Bool
    var lock: Bool
    var logout: Bool
    var nativeFlow: Bool
}

//
//  InstaUserShort.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct UserShortModel: Codable {
    var isVerified: Bool
    var isPrivate: Bool
    var pk: Int
    var profilePicUrl: String
    var username: String
    var fullName: String
    
    init() {
        isVerified = false
        isPrivate = false
        pk = 0
        profilePicUrl = ""
        username = ""
        fullName = ""
    }
    
    func eqauls(user: UserShortModel) -> Bool {
        return pk == user.pk
    }
    
    func getHashCode() -> Int {
        return pk.hashValue
    }
}

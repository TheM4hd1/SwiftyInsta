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
    var profilePicture: String
    var profilePictureId: String = "unknown"
    var username: String
    var fullname: String
    
    func eqauls(user: UserShortModel) -> Bool {
        return pk == user.pk
    }
    
    func getHashCode() -> Int {
        return pk.hashValue
    }
}

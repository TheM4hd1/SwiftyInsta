//
//  InstaUserShort.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

protocol UserShortProtocol {
    var isVerified: Bool? {get}
    var isPrivate: Bool? {get}
    var pk: Int? {get}
    var profilePicUrl: String? {get}
    var profilePicId: String? {get}
    var username: String? {get}
    var fullName: String? {get}
}

struct UserShortModel: Codable, UserShortProtocol, LocationProtocol {
    var isVerified: Bool?
    var isPrivate: Bool?
    var pk: Int?
    var profilePicUrl: String?
    var profilePicId: String?
    var username: String?
    var fullName: String?
    var name: String?
    var address: String?
    var shortName: String?
    var lng: Double?
    var lat: Double?
    var externalSource: String?
    var facebookPlacesId: Int?
    var city: String?
    
    init() {
        isVerified = false
        isPrivate = false
        pk = 0
        profilePicUrl = ""
        profilePicId = ""
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

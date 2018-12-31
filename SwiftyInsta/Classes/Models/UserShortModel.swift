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
    var biography: String? {get}
}

public struct UserShortModel: Codable, UserShortProtocol, LocationProtocol {
    public var isVerified: Bool?
    public var isPrivate: Bool?
    public var pk: Int?
    public var profilePicUrl: String?
    public var profilePicId: String?
    public var username: String?
    public var fullName: String?
    public var name: String?
    public var address: String?
    public var shortName: String?
    public var lng: Double?
    public var lat: Double?
    public var externalSource: String?
    public var facebookPlacesId: Int?
    public var city: String?
    public var biography: String?
    
    public init() {
        isVerified = false
        isPrivate = false
        pk = 0
        profilePicUrl = ""
        profilePicId = ""
        username = ""
        fullName = ""
    }
    
    public init(isVerified: Bool?, isPrivate: Bool?, pk: Int?, profilePicUrl: String?, profilePicId: String?, username: String?, fullName: String?, name: String?, address: String?, shortName: String?, lng: Double?, lat: Double?, externalSource: String?, facebookPlacesId: Int?, city: String?, biography: String?) {
        self.isVerified = isVerified
        self.isPrivate = isPrivate
        self.pk = pk
        self.profilePicUrl = profilePicUrl
        self.profilePicId = profilePicId
        self.username = username
        self.fullName = fullName
        self.name = name
        self.address = address
        self.shortName = shortName
        self.lng = lng
        self.lat = lat
        self.externalSource = externalSource
        self.facebookPlacesId = facebookPlacesId
        self.city = city
        self.biography = biography
    }
    
    func eqauls(user: UserShortModel) -> Bool {
        return pk == user.pk
    }
    
    func getHashCode() -> Int {
        return pk.hashValue
    }
}

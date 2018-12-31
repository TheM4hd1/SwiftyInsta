//
//  LocationModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

protocol LocationProtocol {
    var pk: Int? {get}
    var name: String? {get}
    var address: String? {get}
    var city: String? {get}
    var shortName: String? {get}
    var lng: Double? {get}
    var lat: Double? {get}
    var externalSource: String? {get}
    var facebookPlacesId: Int? {get}
 }

public struct LocationShortModel: Codable, LocationProtocol {
    public var pk: Int?
    public var name: String?
    public var address: String?
    public var city: String?
    public var shortName: String?
    public var lng: Double?
    public var lat: Double?
    public var externalSource: String?
    public var facebookPlacesId: Int?
    
    public init(pk: Int?, name: String?, address: String?, city: String?, shortName: String?, lng: Double?, lat: Double?, externalSource: String?, facebookPlacedId: Int?) {
        self.pk = pk
        self.name = name
        self.address = address
        self.city = city
        self.shortName = shortName
        self.lng = lng
        self.lat = lat
        self.externalSource = externalSource
        self.facebookPlacesId = facebookPlacedId
    }
}

public struct LocationModel: Codable {
    public var x: Double?
    public var y: Double?
    public var z: Double?
    public var width: Double?
    public var height: Double?
    public var rotation: Double?
    public var isPinned: Double?
    public var isHidden: Int?
    public var location: LocationShortModel?
    
    public init(x: Double?, y: Double?, z: Double?, width: Double?, height: Double?, rotation: Double?, isPinned: Double?, isHidden: Int?, location: LocationShortModel?) {
        self.x = x
        self.y = y
        self.z = z
        self.width = width
        self.height = height
        self.rotation = rotation
        self.isPinned = isPinned
        self.isHidden = isHidden
        self.location = location
    }
}

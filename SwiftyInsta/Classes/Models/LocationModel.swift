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

struct LocationShortModel: Codable, LocationProtocol {
    var pk: Int?
    var name: String?
    var address: String?
    var city: String?
    var shortName: String?
    var lng: Double?
    var lat: Double?
    var externalSource: String?
    var facebookPlacesId: Int?
}

struct LocationModel: Codable {
    var x: Double?
    var y: Double?
    var z: Double?
    var width: Double?
    var height: Double?
    var rotation: Double?
    var isPinned: Double?
    var isHidden: Int?
    var location: LocationShortModel?
}

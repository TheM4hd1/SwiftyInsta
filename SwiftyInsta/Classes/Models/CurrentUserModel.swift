//
//  CurrentUserModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/6/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct CurrentUser: Codable, UserShortProtocol {
    var isVerified: Bool?
    var isPrivate: Bool?
    var pk: Int?
    var profilePicUrl: String?
    var profilePicId: String?
    var username: String?
    var fullName: String?
    var hasAnonymousProfilePicture: Bool?
    var biography: String?
    var externalUrl: String?
    var showConversionEditEntry: Bool?
    var birthday: String?
    var phoneNumber: String?
    var gender: Int?
    var email: String?
    var needsEmailConfirm: Bool?
    var hdProfilePicVersions: [ProfilePicVersionsModel]?
    var hdProfilePicUrlInfo: ProfilePicVersionsModel?
}

struct CurrentUserModel: Codable, BaseStatusResponseProtocol {
    var user: CurrentUser
    var status: String?
}

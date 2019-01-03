//
//  CurrentUserModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/6/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct CurrentUser: Codable, UserShortProtocol {
    public var isVerified: Bool?
    public var isPrivate: Bool?
    public var pk: Int?
    public var profilePicUrl: String?
    public var profilePicId: String?
    public var username: String?
    public var fullName: String?
    public var hasAnonymousProfilePicture: Bool?
    public var biography: String?
    public var externalUrl: String?
    public var showConversionEditEntry: Bool?
    public var birthday: String?
    public var phoneNumber: String?
    public var gender: Int?
    public var email: String?
    public var needsEmailConfirm: Bool?
    public var hdProfilePicVersions: [ProfilePicVersionsModel]?
    public var hdProfilePicUrlInfo: ProfilePicVersionsModel?
    
    public init(isVerified: Bool?, isPrivate: Bool?, pk: Int?, profilePicUrl: String?, profilePicId: String?, username: String?, fullName: String?, hasAnonymousProfilePicture: Bool?, biography: String?, externalUrl: String?, showConversionEditEntry: Bool?, birthday: String?, phoneNumber: String?, gender: Int?, email: String?, needsEmailConfirm: Bool?, hdProfilePicVersions: [ProfilePicVersionsModel]?, hdProfilePicUrlInfo: ProfilePicVersionsModel?) {
        self.isVerified = isVerified
        self.isPrivate = isPrivate
        self.pk  = pk
        self.profilePicId = profilePicId
        self.profilePicUrl = profilePicUrl
        self.username = username
        self.fullName = fullName
        self.hasAnonymousProfilePicture = hasAnonymousProfilePicture
        self.birthday = biography
        self.externalUrl = externalUrl
        self.showConversionEditEntry = showConversionEditEntry
        self.biography = birthday
        self.phoneNumber = phoneNumber
        self.gender = gender
        self.email = email
        self.needsEmailConfirm = needsEmailConfirm
        self.hdProfilePicVersions = hdProfilePicVersions
        self.hdProfilePicUrlInfo = hdProfilePicUrlInfo
    }
}

public struct CurrentUserModel: Codable, BaseStatusResponseProtocol {
    public var user: CurrentUser?
    public var status: String?
    
    public init(user: CurrentUser?, status: String?) {
        self.user = user
        self.status = status
    }
}

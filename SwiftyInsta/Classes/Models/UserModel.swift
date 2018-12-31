//
//  UserModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/31/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct UserModel: Codable, UserShortProtocol {
    public var isVerified: Bool?
    public var isPrivate: Bool?
    public var pk: Int?
    public var profilePicUrl: String?
    public var profilePicId: String?
    public var username: String?
    public var fullName: String?
    public var socialContext: String?
    public var searchSocialContext: String?
    public var allowedCommenterType: String?
    public var phoneNumber: String?
    public var reelAutoArchive: String?
    public var byline: String?
    public var externalUrl: String?
    public var email: String?
    public var hasAnonymousProfilePicture: Bool?
    public var isBusiness: Bool?
    public var canBoostPost: Bool?
    public var showInsightsTerms: Bool?
    public var hasPlacedOrders: Bool?
    public var canSeeOrganicInsights: Bool?
    public var allowContactsSync: Bool?
    public var followerCount: Int?
    public var countryCode: Int?
    public var nationalNumber: Int?
    public var unseenCount: Int?
    public var mutualFollowersCount: Int?
    public var nametag: NameTagModel?
    public var friendshipStatus: FriendshipStatusModel?
    public var biography: String?
    public var hdProfilePicVersions: [ProfilePicVersionsModel]?
    public var showBusinessConversionIcon: Bool?
    public var isPotentialBusiness: Bool?
    public var canConvertToBusiness: Bool?
    
    public init(isVerified: Bool?, isPrivate: Bool?, pk: Int?, profilePicUrl: String?, profilePicId: String?, username: String?, fullName: String?, socialContext: String?, searchSocialContext: String?, allowedCommenterType: String, phoneNumber: String?, reelAutoArchive: String?, byline: String?, externalUrl: String?, email: String?, hasAnonymousProfilePicture: Bool?, isBusiness: Bool?, canBoostPost: Bool?, showInsightsTerms: Bool?, hasPlacedOrders: Bool?, canSeeOrganicInsights: Bool?, allowContactsSync: Bool?, followerCount: Int?, countryCode: Int?, nationalNumber: Int?, unseenCount: Int?, mutualFollowersCount: Int?, nametag: NameTagModel?, friendshipStatus: FriendshipStatusModel?, biography: String?, hdProfilePicVersions: [ProfilePicVersionsModel]?, showBusinessConversionIcon: Bool?, isPotentialBusiness: Bool?, canConvertToBusiness: Bool?) {
        self.isVerified = isVerified
        self.isPrivate = isPrivate
        self.pk = pk
        self.profilePicUrl = profilePicUrl
        self.profilePicId = profilePicId
        self.username = username
        self.fullName = fullName
        self.socialContext = socialContext
        self.searchSocialContext = searchSocialContext
        self.allowedCommenterType = allowedCommenterType
        self.phoneNumber = phoneNumber
        self.reelAutoArchive = reelAutoArchive
        self.byline = byline
        self.externalUrl = externalUrl
        self.email = email
        self.hasAnonymousProfilePicture = hasAnonymousProfilePicture
        self.isBusiness = isBusiness
        self.canBoostPost = canBoostPost
        self.showInsightsTerms = showInsightsTerms
        self.hasPlacedOrders = hasPlacedOrders
        self.canSeeOrganicInsights = canSeeOrganicInsights
        self.allowContactsSync = allowContactsSync
        self.followerCount = followerCount
        self.countryCode = countryCode
        self.nationalNumber = nationalNumber
        self.unseenCount = unseenCount
        self.mutualFollowersCount = mutualFollowersCount
        self.nametag = nametag
        self.friendshipStatus = friendshipStatus
        self.biography = biography
        self.hdProfilePicVersions = hdProfilePicVersions
        self.showBusinessConversionIcon = showBusinessConversionIcon
        self.isPotentialBusiness = isPotentialBusiness
        self.canConvertToBusiness = canConvertToBusiness
    }
}

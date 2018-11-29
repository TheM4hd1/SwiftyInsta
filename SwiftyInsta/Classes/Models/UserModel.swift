//
//  UserModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/31/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct UserModel: Codable, UserShortProtocol {
    var isVerified: Bool?
    var isPrivate: Bool?
    var pk: Int?
    var profilePicUrl: String?
    var profilePicId: String?
    var username: String?
    var fullName: String?
    var socialContext: String?
    var searchSocialContext: String?
    var allowedCommenterType: String?
    var phoneNumber: String?
    var reelAutoArchive: String?
    var byline: String?
    var externalUrl: String?
    var email: String?
    var hasAnonymousProfilePicture: Bool?
    var isBusiness: Bool?
    var canBoostPost: Bool?
    var showInsightsTerms: Bool?
    var has_placed_orders: Bool?
    var can_see_organic_insights: Bool?
    var allow_contacts_sync: Bool?
    var followerCount: Int?
    var countryCode: Int?
    var nationalNumber: Int?
    var unseenCount: Int?
    var mutualFollowersCount: Int?
    var nametag: NameTagModel?
    var friendshipStatus: FriendshipStatusModel?
    var biography: String?
    var hdProfilePicVersions: [ProfilePicVersionsModel]?
    var showBusinessConversionIcon: Bool?
    var isPotentialBusiness: Bool?
    var canConvertToBusiness: Bool?
}

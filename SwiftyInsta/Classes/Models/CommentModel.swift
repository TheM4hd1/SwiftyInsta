//
//  CommentModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/13/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct CommentModel: Codable {
    var pk: Int?
    var userId: Int?
    var text: String?
    var contentType: String?
    var status: String?
    var user: UserShortModel?
    var didReportAsSpam: Bool?
    var shareEnabled: Bool?
    var hasLikedComment: Bool?
    var commentLikeCount: Int?
}

struct MediaCommentsResponseModel: Codable, BaseStatusResponseProtocol {
    var commentLikesEnabled: Bool?
    var comments: [CommentModel]?
    var commentCount: Int?
    var caption: CaptionModel?
    var captionIsEdited: Bool?
    var hasMoreComments: Bool?
    var previewComments: [CommentModel]?
    var nextMaxId: String?
    var status: String?
}

struct CommentResponse: Codable, BaseStatusResponseProtocol {
    var comment: CommentModel?
    var status: String?
}

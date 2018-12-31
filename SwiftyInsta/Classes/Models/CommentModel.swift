//
//  CommentModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/13/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct CommentModel: Codable {
    public var pk: Int?
    public var userId: Int?
    public var text: String?
    public var contentType: String?
    public var status: String?
    public var user: UserShortModel?
    public var didReportAsSpam: Bool?
    public var shareEnabled: Bool?
    public var hasLikedComment: Bool?
    public var commentLikeCount: Int?
    
    public init(pk: Int?, userId: Int?, text: String?, contentType: String?, status: String?, user: UserShortModel?, didReportAsSpam: Bool?, shareEnabled: Bool?, hasLikedComment: Bool?, commentLikeCount: Int?) {
        self.pk = pk
        self.userId = userId
        self.contentType = contentType
        self.status = status
        self.user = user
        self.didReportAsSpam = didReportAsSpam
        self.shareEnabled = shareEnabled
        self.hasLikedComment = hasLikedComment
        self.commentLikeCount = commentLikeCount
    }
}

public struct MediaCommentsResponseModel: Codable, BaseStatusResponseProtocol {
    public var commentLikesEnabled: Bool?
    public var comments: [CommentModel]?
    public var commentCount: Int?
    public var caption: CaptionModel?
    public var captionIsEdited: Bool?
    public var hasMoreComments: Bool?
    public var previewComments: [CommentModel]?
    public var nextMaxId: String?
    public var status: String?
    
    public init(commentLikesEnabled: Bool?, comments: [CommentModel]?, commentCount: Int?, caption: CaptionModel?, captionIsEdited: Bool?, hasMoreComments: Bool?, previewComments: [CommentModel]?, nextMaxId: String?, status: String?) {
        self.commentLikesEnabled = commentLikesEnabled
        self.comments = comments
        self.commentCount = commentCount
        self.caption = caption
        self.captionIsEdited = captionIsEdited
        self.hasMoreComments = hasMoreComments
        self.previewComments = previewComments
        self.nextMaxId = nextMaxId
        self.status = status
    }
}

public struct CommentResponse: Codable, BaseStatusResponseProtocol {
    public var comment: CommentModel?
    public var status: String?
    
    public init(comment: CommentModel?, status: String?) {
        self.comment = comment
        self.status = status
    }
}

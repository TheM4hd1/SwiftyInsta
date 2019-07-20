//
//  FeedHandler.swift
//
//  Modified by Stefano Bertagno on 11/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public protocol FeedHandlerProtocol {
    func getExploreFeeds(paginationParameters: PaginationParameters,
                         updateHandler: PaginationResponse<ExploreFeedModel>?,
                         completionHandler: @escaping PaginationResponse<Result<[ExploreFeedModel]>>) throws
    func getTagFeed(tag: String,
                    paginationParameters: PaginationParameters,
                    updateHandler: PaginationResponse<TagFeedModel>?,
                    completionHandler: @escaping PaginationResponse<Result<[TagFeedModel]>>) throws
    func getUserTimeLine(paginationParameters: PaginationParameters,
                         updateHandler: PaginationResponse<TimeLineModel>?,
                         completionHandler: @escaping PaginationResponse<Result<[TimeLineModel]>>) throws
}

class FeedHandler: FeedHandlerProtocol {
    static let shared = FeedHandler()
    
    // MARK: Private
    private init() {
    }

    // MARK: Protocol conformacy
    public func getExploreFeeds(paginationParameters: PaginationParameters,
                                updateHandler: PaginationResponse<ExploreFeedModel>?,
                                completionHandler: @escaping PaginationResponse<Result<[ExploreFeedModel]>>) throws {
        PaginationHandler.getPages(ExploreFeedModel.self,
                                   for: paginationParameters,
                                   at: { try URLs.getExploreFeedUrl(maxId: $0.nextMaxId ?? "") },
                                   updateHandler: updateHandler,
                                   completionHandler: completionHandler)
    }
    
    func getTagFeed(tag: String,
                    paginationParameters: PaginationParameters,
                    updateHandler: PaginationResponse<TagFeedModel>?,
                    completionHandler: @escaping PaginationResponse<Result<[TagFeedModel]>>) throws {
        PaginationHandler.getPages(TagFeedModel.self,
                                   for: paginationParameters,
                                   at: { try URLs.getTagFeed(for: tag, maxId: $0.nextMaxId ?? "") },
                                   updateHandler: updateHandler,
                                   completionHandler: completionHandler)
    }
    
    func getUserTimeLine(paginationParameters: PaginationParameters,
                         updateHandler: PaginationResponse<TimeLineModel>?,
                         completionHandler: @escaping PaginationResponse<Result<[TimeLineModel]>>) throws {
        PaginationHandler.getPages(TimeLineModel.self,
                                   for: paginationParameters,
                                   at: { try URLs.getUserTimeLineUrl(maxId: $0.nextMaxId ?? "") },
                                   updateHandler: updateHandler,
                                   completionHandler: completionHandler)
    }
}

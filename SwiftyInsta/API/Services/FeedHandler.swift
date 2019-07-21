//
//  FeedHandler.swift
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public class FeedHandler: Handler {
    /// Fetch the explore feed.
    public func explore(with paginationParameters: PaginationParameters,
                        updateHandler: PaginationUpdateHandler<ExploreFeedModel>?,
                        completionHandler: @escaping PaginationCompletionHandler<ExploreFeedModel>) {
        pages.fetch(ExploreFeedModel.self,
                    with: paginationParameters,
                    at: { try URLs.getExploreFeedUrl(maxId: $0.nextMaxId ?? "") },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }

    /// Fetch the tag feed.
    public func tag(_ tag: String,
                    with paginationParameters: PaginationParameters,
                    updateHandler: PaginationUpdateHandler<TagFeedModel>?,
                    completionHandler: @escaping PaginationCompletionHandler<TagFeedModel>) {
        pages.fetch(TagFeedModel.self,
                    with: paginationParameters,
                    at: { try URLs.getTagFeed(for: tag, maxId: $0.nextMaxId ?? "") },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }
        
    /// Fetch the timeline.
    public func timeline(with paginationParameters: PaginationParameters,
                         updateHandler: PaginationUpdateHandler<TimelineModel>?,
                         completionHandler: @escaping PaginationCompletionHandler<TimelineModel>) {
        pages.fetch(TimelineModel.self,
                    with: paginationParameters,
                    at: { try URLs.getUserTimeLineUrl(maxId: $0.nextMaxId ?? "") },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }
}

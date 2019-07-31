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
                    at: { URLs.getExploreFeedUrl(maxId: $0.nextMaxId ?? "") },
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
                    at: { URLs.getTagFeed(for: tag, maxId: $0.nextMaxId ?? "") },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }

    /// Fetch the timeline.
    public func timeline(with paginationParameters: PaginationParameters,
                         updateHandler: PaginationUpdateHandler<TimelineModel>?,
                         completionHandler: @escaping PaginationCompletionHandler<TimelineModel>) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")),
                                     paginationParameters)
        }
        // prepare body.
        let body: [String: Any] = [
            "is_prefetch": 0,
            "is_pull_to_refresh": 0,
            "feed_view_info": "",
            "seen_posts": "",
            "phone_id": handler.settings.device.phoneGuid,
            "battery_level": 72,
            "timezone_offset": Headers.timeZoneOffsetValue,
            "_csrftoken": storage.csrfToken,
            "client_session_id": storage.sessionId,
            "device_id": handler.settings.device.id,
            "_uuid": storage.dsUserId,
            "is_charging": 0,
            "will_sound_on": 1,
            "is_on_screen": "true",
            "is_async_ads_in_headload_enabled": "false",
            "rti_delivery_backend": "false",
            "is_async_ads_double_request": "false",
            "is_async_ads_rti": "false",
            "latest_story_pk": ""
        ]
        let headers = ["X-Ads-Opt-Out": "0",
                       "X-Google-AD-ID": handler.settings.device.googleAdId.uuidString,
                       "X-DEVICE-ID": handler.settings.device.deviceGuid.uuidString,
                       "X-FB": "1"]

        pages.fetch(TimelineModel.self,
                    with: paginationParameters,
                    at: { _ in URLs.getUserTimeLineUrl(maxId: "") }, //$0.nextMaxId ?? "") },
                    body: {
                        switch $0.nextMaxId {
                        case .none:
                            return .gzip(body.merging(["reason": "cold_start_fresh"],
                                                      uniquingKeysWith: { lhs, _ in lhs }))
                        case let maxId?:
                            return .gzip(body.merging(["reason": "pagination", "max_id": maxId],
                                                      uniquingKeysWith: { lhs, _ in lhs }))
                        }
                    },
                    headers: { _ in headers },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }
}

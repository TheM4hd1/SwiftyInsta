//
//  FeedHandler.swift
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public final class FeedHandler: Handler {
    /// Fetch the explore feed.
    public func explore(with paginationParameters: PaginationParameters,
                        updateHandler: PaginationUpdateHandler<ExploreElement, AnyPaginatedResponse>?,
                        completionHandler: @escaping PaginationCompletionHandler<ExploreElement>) {
        pages.parse(ExploreElement.self,
                    paginatedResponse: AnyPaginatedResponse.self,
                    with: paginationParameters,
                    at: { try URLs.getExploreFeedUrl(maxId: $0.nextMaxId ?? "") },
                    processingHandler: { $0.rawResponse.items.array?.map(ExploreElement.init) ?? [] },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }

    /// Fetch the tag feed.
    public func tag(_ tag: String,
                    with paginationParameters: PaginationParameters,
                    updateHandler: PaginationUpdateHandler<Media, AnyPaginatedResponse>?,
                    completionHandler: @escaping PaginationCompletionHandler<Media>) {
        pages.parse(Media.self,
                    paginatedResponse: AnyPaginatedResponse.self,
                    with: paginationParameters,
                    at: { try URLs.getTagFeed(for: tag, maxId: $0.nextMaxId ?? "") },
                    processingHandler: { $0.rawResponse.items.array?.map(Media.init) ?? [] },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }

    @available(*, unavailable, message: "Instagram changed this endpoint. We're working on making it work again.")
    /// Fetch the timeline.
    public func timeline(with paginationParameters: PaginationParameters,
                         updateHandler: PaginationUpdateHandler<Media, AnyPaginatedResponse>?,
                         completionHandler: @escaping PaginationCompletionHandler<Media>) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")),
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

        pages.parse(Media.self,
                    paginatedResponse: AnyPaginatedResponse.self,
                    with: paginationParameters,
                    at: { _ in try URLs.getUserTimeLineUrl(maxId: "") },
                    body: {
                        switch $0.nextMaxId {
                        case .none:
                            return .parameters(body.merging(["reason": "cold_start_fresh"],
                                                            uniquingKeysWith: { lhs, _ in lhs }))
                        case let maxId?:
                            return .parameters(body.merging(["reason": "pagination", "max_id": maxId],
                                                            uniquingKeysWith: { lhs, _ in lhs }))
                        }
        },
                    headers: { _ in headers },
                    processingHandler: { $0.rawResponse.feedItems.array?.map { Media(rawResponse: $0.mediaOrAd) } ?? [] },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }
}

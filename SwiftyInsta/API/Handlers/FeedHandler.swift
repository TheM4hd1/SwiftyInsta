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
        pages.request(ExploreElement.self,
                      page: AnyPaginatedResponse.self,
                      with: paginationParameters,
                      endpoint: { Endpoint.Discover.explore.next($0.nextMaxId) },
                      splice: { $0.rawResponse.items.array?.compactMap(ExploreElement.init) ?? [] },
                      update: updateHandler,
                      completion: completionHandler)
    }

    /// Fetch the liked feed.
    public func liked(with paginationParameters: PaginationParameters,
                      updateHandler: PaginationUpdateHandler<Media, AnyPaginatedResponse>?,
                      completionHandler: @escaping PaginationCompletionHandler<Media>) {
        pages.request(Media.self,
                      page: AnyPaginatedResponse.self,
                      with: paginationParameters,
                      endpoint: { Endpoint.Feed.liked.next($0.nextMaxId) },
                      splice: { $0.rawResponse.items.array?.compactMap(Media.init) ?? [] },
                      update: updateHandler,
                      completion: completionHandler)
    }

    /// Fetch the tag feed.
    public func tag(_ tag: String,
                    with paginationParameters: PaginationParameters,
                    updateHandler: PaginationUpdateHandler<Media, AnyPaginatedResponse>?,
                    completionHandler: @escaping PaginationCompletionHandler<Media>) {
        pages.request(Media.self,
                      page: AnyPaginatedResponse.self,
                      with: paginationParameters,
                      endpoint: { Endpoint.Feed.tag.tag(tag).next($0.nextMaxId) },
                      splice: { $0.rawResponse.items.array?.compactMap(Media.init) ?? [] },
                      update: updateHandler,
                      completion: completionHandler)
    }

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
            "timezone_offset": Constants.timeZoneOffsetValue,
            "_csrftoken": storage.csrfToken,
            "client_session_id": storage.sessionId,
            "device_id": handler.settings.device.id,
            "_uuid": storage.dsUserId,
            "is_charging": 0,
            "will_sound_on": 1,
            "is_on_screen": "true",
            "is_async_ads_in_headload_enabled": "false",
            "is_async_ads_double_request": "false",
            "is_async_ads_rti": "false",
            "latest_story_pk": ""
        ]
        let headers = ["X-Ads-Opt-Out": "0",
                       "X-Google-AD-ID": handler.settings.device.googleAdId.uuidString,
                       "X-DEVICE-ID": handler.settings.device.deviceGuid.uuidString,
                       "X-FB": "1"]

        pages.request(Media.self,
                      page: AnyPaginatedResponse.self,
                      with: paginationParameters,
                      endpoint: { Endpoint.Feed.timeline.next($0.nextMaxId) },
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
                      splice: { $0.rawResponse.feedItems.array?.compactMap { Media(rawResponse: $0.mediaOrAd) } ?? [] },
                      update: updateHandler,
                      completion: completionHandler)
    }
}

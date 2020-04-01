//
//  PaginationParameters.swift
//  SwiftyInsta
//
//  Modified by Stefano Bertagno on 11/3/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public class PaginationParameters {
    /// The maximum number of pages to load. Defaults to `1`.
    public var maxPagesToLoad: Int
    /// The number of pages already loaded. Defaults to `0`.
    public var loadedPages: Int = 0
    /// The current request `maxId`. Defaults to `nil`.
    public var currentMaxId: String?
    /// The next `maxId`. Defaults to `nil`.
    public var nextMaxId: String?

    /// Whether there's something left to load.
    var canLoadMore: Bool { return loadedPages < maxPagesToLoad }

    // MARK: Init
    public init(startingAt maxId: String? = nil, maxPagesToLoad: Int = 1) {
        precondition(maxPagesToLoad > 0, "`maxPagesToLoad` must be bigger than `0`.")
        self.nextMaxId = maxId
        self.maxPagesToLoad = maxPagesToLoad
    }
    public init(_ paginationParameters: PaginationParameters) {
        self.nextMaxId = paginationParameters.nextMaxId
        self.maxPagesToLoad = paginationParameters.maxPagesToLoad
    }
    public static let everything = PaginationParameters(startingAt: nil, maxPagesToLoad: .max)

    // MARK: Obsolete
    @available(*, unavailable, message: "use `init` instead.")
    public static func maxPagesToLoad(maxPages: Int) -> PaginationParameters {
        fatalError("`maxPagesToLoad(maxPages:)` was removed.")
    }
}

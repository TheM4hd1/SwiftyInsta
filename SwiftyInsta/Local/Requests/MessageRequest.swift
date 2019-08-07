//
//  MessageRequest.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 06/08/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public extension Recipient {
    /// An `enum` holding reference to a possible `Recipient`.
    enum Reference {
        /// An array of `Recipient`s primary keys.
        case users(_ primaryKeys: [Int])
        /// The given thread identifier.
        case thread(String)
    }
}

//
//  DynamicRequest.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 06/08/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// A reference to a `Dynamic` request.
public typealias DynamicRequest = DynamicResponse

// Althoguh `DynamicRequest` is provided to the user,
// most methods and endpoints, still prefer directly
// encoding a specific `Codable` struct, instead.
// This might change in the future.

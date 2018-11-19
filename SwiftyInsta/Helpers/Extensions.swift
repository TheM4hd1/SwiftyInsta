//
//  Extensions.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/19/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

extension Data {
    mutating func append(string: String) {
        let data = string.data(
            using: String.Encoding.utf8,
            allowLossyConversion: true)
        append(data!)
    }
}

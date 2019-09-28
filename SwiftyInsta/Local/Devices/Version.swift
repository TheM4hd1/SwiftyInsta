//
//  AndroidVersion.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/18/18.
//  V. 2.0 by Stefano Bertagno on 7/31/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

/// A `struct` to generate **Android-specific** O.S. info.
struct Version: Equatable {
    /// The code name.
    let name: String
    /// The number.
    let number: String
    /// The API level.
    let apiLevel: String

    /// All supported `Version`s.
    static let all: [Version] = [
        Version(name: "Ice Cream Sandwich", number: "4.0", apiLevel: "14"),
        Version(name: "Ice Cream Sandwich", number: "4.0.3", apiLevel: "15"),
        Version(name: "Jelly Bean", number: "4.1", apiLevel: "16"),
        Version(name: "Jelly Bean", number: "4.2", apiLevel: "17"),
        Version(name: "Jelly Bean", number: "4.3", apiLevel: "18"),
        Version(name: "KitKat", number: "4.4", apiLevel: "19"),
        Version(name: "KitKat", number: "5.0", apiLevel: "21"),
        Version(name: "Lollipop", number: "5.1", apiLevel: "22"),
        Version(name: "Marshmallow", number: "6.0", apiLevel: "23"),
        Version(name: "Nougat", number: "7.0", apiLevel: "23"),
        Version(name: "Nougat", number: "7.1", apiLevel: "25")
    ]
    /// Init a specific `Version`.
    init(name: String, number: String, apiLevel: String) {
        self.name = name
        self.number = number
        self.apiLevel = apiLevel
    }
    /// Init a specific `Version` from a given `string`.
    init(from string: String) throws {
        let optionalElement = Version.all.enumerated().first {
            return string.compare($0.element.number) == .orderedSame
                || (string.compare($0.element.number) == .orderedDescending
                    && $0.offset != Version.all.count-1
                    && string.compare(Version.all[$0.offset+1].number) == .orderedDescending)
        }?.element
        // check for optional.
        guard let element = optionalElement else { throw GenericError.custom("Wrong Android version.") }
        self.name = element.name
        self.number = element.number
        self.apiLevel = element.apiLevel
    }
}

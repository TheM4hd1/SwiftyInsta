//
//  AndroidVersion.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/18/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct AndroidVersion: Equatable {
    let codeName: String
    let versionNumber: String
    let apiLevel: String
    
    private static let androidList: [AndroidVersion] = [
        AndroidVersion(codeName: "Ice Cream Sandwich", versionNumber: "4.0", apiLevel: "14"),
        AndroidVersion(codeName: "Ice Cream Sandwich", versionNumber: "4.0.3", apiLevel: "15"),
        AndroidVersion(codeName: "Jelly Bean", versionNumber: "4.1", apiLevel: "16"),
        AndroidVersion(codeName: "Jelly Bean", versionNumber: "4.2", apiLevel: "17"),
        AndroidVersion(codeName: "Jelly Bean", versionNumber: "4.3", apiLevel: "18"),
        AndroidVersion(codeName: "KitKat", versionNumber: "4.4", apiLevel: "19"),
        AndroidVersion(codeName: "KitKat", versionNumber: "5.0", apiLevel: "21"),
        AndroidVersion(codeName: "Lollipop", versionNumber: "5.1", apiLevel: "22"),
        AndroidVersion(codeName: "Marshmallow", versionNumber: "6.0", apiLevel: "23"),
        AndroidVersion(codeName: "Nougat", versionNumber: "7.0", apiLevel: "23"),
        AndroidVersion(codeName: "Nougat", versionNumber: "7.1", apiLevel: "25")
    ]
    static func fromString(versionString: String) -> AndroidVersion? {
        for android in androidList {
            if versionString.compare(android.versionNumber) == ComparisonResult.orderedSame ||
                (versionString.compare(android.versionNumber) == ComparisonResult.orderedDescending &&
                android != androidList.last! &&
                versionString.compare(androidList[androidList.firstIndex(of: android)! + 1].versionNumber) == ComparisonResult.orderedAscending) {
                return android
            }
        }
        return nil
    }
    
    static func ==(lhs: AndroidVersion, rhs: AndroidVersion) -> Bool {
        return (
            lhs.codeName == rhs.codeName &&
            lhs.apiLevel == rhs.apiLevel &&
            lhs.versionNumber == rhs.versionNumber
        )
    }
}

//
//  ChallengeModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/29/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct ChallengeForm: Codable {
    var entryData: EntryData?

    /// Compute and return the suggestion.
    var suggestion: [String]? {
        guard let values = entryData?.challenge?.first?.extraData?.content?.last?.fields?.first?.values,
            values.count == 2 else { return nil }
        let first = values[0]
        let last = values[1]
        // check for.
        return Array(Set([first.label, last.label].compactMap { $0 }))
    }
}
extension ChallengeForm {
    struct EntryData: Codable {
        enum CodingKeys: String, CodingKey {
            case challenge = "Callenge"
        }
        var challenge: [EntryDataChallengeItem]?
    }
}
extension ChallengeForm.EntryData {
    struct EntryDataChallengeItem: Codable {
        var extraData: ChallengeItemExtraData?
    }
}
extension ChallengeForm.EntryData.EntryDataChallengeItem {
    struct ChallengeItemExtraData: Codable {
        var content: [ExtraDataContent]?
    }
}
extension ChallengeForm.EntryData.EntryDataChallengeItem.ChallengeItemExtraData {
    struct ExtraDataContent: Codable {
        var fields: [ContentField]?
    }
}
extension ChallengeForm.EntryData.EntryDataChallengeItem.ChallengeItemExtraData.ExtraDataContent {
    struct ContentField: Codable {
        var values: [FieldsItem]?
    }
}
extension ChallengeForm.EntryData.EntryDataChallengeItem.ChallengeItemExtraData.ExtraDataContent.ContentField {
    struct FieldsItem: Codable {
        var label: String?
        var selected: Bool?
        var value: Int?
    }
}

struct ChallengeModel: Codable {
    var url: String
    var apiPath: String
    var hideWebviewHeader: Bool
    var lock: Bool
    var logout: Bool
    var nativeFlow: Bool

    init(url: String, apiPath: String, hideWebviewHeader: Bool, lock: Bool, logout: Bool, nativeFlow: Bool) {
        self.url = url
        self.apiPath = apiPath
        self.hideWebviewHeader = hideWebviewHeader
        self.lock = lock
        self.logout = logout
        self.nativeFlow = nativeFlow
    }
}

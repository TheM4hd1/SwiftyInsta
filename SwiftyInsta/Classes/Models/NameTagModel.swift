//
//  NameTagModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/31/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct NameTagModel: Codable {
    var mode: Int?
    var gradient: Int?
    var emoji: String?
    var selfieSticker: Int?
    
    private enum CodingKeys: String, CodingKey {
        case mode = "mode"
        case gradient = "gradient"
        case emoji = "emoji"
        case selfieSticker = "selfie_sticker"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decodeIfPresent(String.self, forKey: .gradient) {
            if let value = value {
                gradient = Int(value)
            } else {
                gradient = try container.decode(Int.self, forKey: .gradient)
            }
        } else {
            gradient = try container.decode(Int.self, forKey: .gradient)
        }
        
        mode = try? container.decode(Int.self, forKey: .mode)
        emoji = try? container.decode(String.self, forKey: .emoji)
        selfieSticker = try? container.decode(Int.self, forKey: .selfieSticker)
    }
}

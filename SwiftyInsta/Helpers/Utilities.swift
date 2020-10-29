//
//  Utilities.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 10/29/20.
//  Copyright © 2020 Mahdi. All rights reserved.
//

import Foundation

struct Utilities {
    /// Encrypt password for authentication.
    static func encryptPassword(from headers: [String: String], _ password: String) -> Result<String, Error> {
        guard let passwordKeyId = headers["ig-set-password-encryption-key-id"].flatMap(UInt8.init),
              let passwordPublicKey = headers["ig-set-password-encryption-pub-key"]
                .flatMap({ Data(base64Encoded: $0) })
                .flatMap({ String(data: $0, encoding: .utf8) }) else {
            return .failure(GenericError.custom("Cannot fetch encryption headers")) }
        let randomKey = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        let iv = Data((0..<12).map { _ in UInt8.random(in: 0...255) })
        let time = "\(Int(Date().timeIntervalSince1970))"
        do {
            let (aesEncrypted, authenticationTag) = try CC.GCM.crypt(.encrypt,
                                                                     algorithm: .aes,
                                                                     data: password.data(using: .utf8)!,
                                                                     key: randomKey,
                                                                     iv: iv,
                                                                     aData: time.data(using: .utf8)!,
                                                                     tagLength: 16)
            // RSA.
            let publicKey = try SwKeyConvert.PublicKey.pemToPKCS1DER(passwordPublicKey)
            let rsaEncrypted = try CC.RSA.encrypt(randomKey,
                                                  derKey: publicKey,
                                                  tag: .init(),
                                                  padding: .pkcs1,
                                                  digest: .none)
            var rsaEncryptedLELength = UInt16(littleEndian: UInt16(rsaEncrypted.count))
            let rsaEncryptedLength = Data(bytes: &rsaEncryptedLELength, count: MemoryLayout<UInt16>.size)
            // Compute `enc_password`.
            var data = Data()
            data.append(1)
            data.append(passwordKeyId)
            data.append(iv)
            data.append(rsaEncryptedLength)
            data.append(rsaEncrypted)
            data.append(authenticationTag)
            data.append(aesEncrypted)
            let encPassword = "#PWD_INSTAGRAM:4:\(time):\(data.base64EncodedString())"
            return .success(encPassword)
        } catch {
            return .failure(error)
        }
    }
}

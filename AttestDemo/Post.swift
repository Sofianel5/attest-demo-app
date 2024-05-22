//
//  Item.swift
//  AttestDemo
//
//  Created by Sofiane Larbi on 5/19/24.
//

import Foundation
import SwiftData
import Security

@Model
final class Post {
    var timestamp: Date
    var photoURL: String
    var photoSig: String
    var posterPk: String
    var posterAttestProof: String
    var locationLat: Double
    var locationLng: Double
    
    init(timestamp: Date,
         photoURL: String,
         photoSig: String,
         posterPk: String,
         posterAttestProof: String,
         locationLat: Double,
         locationLng: Double
    ) {
        self.timestamp = timestamp
        self.photoURL = photoURL
        self.photoSig = photoSig
        self.posterPk = posterPk
        self.posterAttestProof = posterAttestProof
        self.locationLat = locationLat
        self.locationLng = locationLng
    }
    
    static let example = Post(
        timestamp: Date(),
        photoURL: "https://pbs.twimg.com/media/GMzC-4VaEAAEH01?format=jpg&name=medium",
        photoSig: "0x0000",
        posterPk: "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
        posterAttestProof: "0x9999",
        locationLat: -17.34,
        locationLng: 34.043
    )
    
    func formatPostAsMessage() -> String {
        return "\(self.posterPk)|\(self.timestamp)|\(self.photoURL)|\(self.locationLat)|\(self.locationLng)"
    }
    
    func validatePost() -> Bool {
        guard let publicKeyData = Data(base64Encoded: self.posterPk) else {
            fatalError("Failed to decode base64 public key")
        }
        let keyDict: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 2048
        ]
        guard let publicKey = SecKeyCreateWithData(publicKeyData as CFData, keyDict as CFDictionary, nil) else {
            fatalError("Failed to create public key")
        }
        let signature = Data(base64Encoded: self.photoSig)!
        let algorithm: SecKeyAlgorithm = .ecdsaSignatureDigestX962
        return SecKeyVerifySignature(
            publicKey,
            algorithm,
            self.formatPostAsMessage().data(using: .utf8)! as CFData,
            signature as CFData,
            nil
        )
    }
}

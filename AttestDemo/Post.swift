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
    @Attribute(.unique) var photoURL: String
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
    
    convenience init(from dataObject: ServerDataCollection.PostDataObject) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from:dataObject.timestamp)!
        
        self.init(
            timestamp: date,
            photoURL: dataObject.photo_url,
            photoSig: dataObject.photo_signature,
            posterPk: dataObject.poster_pubkey,
            posterAttestProof: dataObject.poster_attest_proof,
            locationLat: Double(dataObject.location_lat)!,
            locationLng: Double(dataObject.location_long)!
        )
    }
    
    static let example = Post(
        timestamp: Date(),
        photoURL: "https://pbs.twimg.com/media/GMzC-4VaEAAEH01?format=jpg&name=medium",
        photoSig: "0x0000",
        posterPk: "0xface",
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

struct ServerDataCollection: Decodable {
    let post_data_objects: [PostDataObject]
    
    struct PostDataObject: Decodable {
        let timestamp: String
        let photo_url: String
        let photo_signature: String
        let poster_pubkey: String
        let poster_attest_proof: String
        let location_lat: String
        let location_long: String
    }
}

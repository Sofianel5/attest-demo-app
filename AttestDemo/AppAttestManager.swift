//
//  AppAttestManager.swift
//  ProofPix
//
//  Created by Sofiane Larbi on 5/17/24.
//

import Foundation
import DeviceCheck
import CryptoKit

class AppAttestManager {
    
    static let shared = AppAttestManager();
    
    private var keyId: String?;
    private var attestation: Data?;
    private let service = DCAppAttestService.shared
    
    func keyGen(callBack: @escaping (String) -> Void) {
        if service.isSupported {
            // Perform key generation and attestation.
            service.generateKey { keyId, error in
                guard error == nil else {
                    self.keyId = nil;
                    print("Failed to generate key ", error!)
                    return
                }
                self.keyId = keyId!;
                callBack(keyId!)
            }
        } else {
            print("appattest service not supported")
        }
    }
    
    func attestKey(challenge: Data, callBack: @escaping (Data) -> Void) {
        if let keyId {
            let hash = Data(SHA256.hash(data: challenge))
            print("Attempting to attest keyId: \(keyId), clientDataHash: \(hash)")
            service.attestKey(keyId, clientDataHash: hash) { attestation, error in
                guard error == nil else {
                    print("service.attestKey error: \(error!)")
                    return
                }
                self.attestation = attestation
                callBack(attestation!)
            }
        } else {
            print("AppAttestManager.attestKey: keyId nil")
        }
    }
    
    func getAttestation() -> Data? {
        return self.attestation;
    }
}

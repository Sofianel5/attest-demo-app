//
//  AppAttestManager.swift
//  ProofPix
//
//  Created by Sofiane Larbi on 5/17/24.
//

import Foundation
import DeviceCheck

class AppAttestManager {
    
    static let shared = AppAttestManager();
    
    private var keyId: String?;
    private var attestation: Data?;
    private let service = DCAppAttestService.shared
    
    init() {
        if service.isSupported {
            // Perform key generation and attestation.
            service.generateKey { keyId, error in
                guard error == nil else {
                    self.keyId = nil;
                    print("Failed to generate key ", error!)
                    return
                }
                self.keyId = keyId!;
            }
        } else {
            print("appattest service not supported")
        }
    }
    
    func isReady() -> Bool {
        return self.keyId != nil;
    }
    
    func attestKey(hash: Data, callBack: @escaping (Data) -> Void) {
        if let keyId {
            service.attestKey(keyId, clientDataHash: hash) { attestation, error in
                guard error == nil else { return }
                self.attestation = attestation
                callBack(attestation!)
            }
        }
    }
    
    func getAttestation() -> Data? {
        return self.attestation;
    }
}

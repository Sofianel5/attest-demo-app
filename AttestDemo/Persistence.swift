//
//  Persistence.swift
//  ProofPix
//
//  Created by Sofiane Larbi on 2/16/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let defaults = UserDefaults.standard
    
    func saveAttestation(attestation: Data) {
        defaults.set(attestation, forKey: "attestation")
    }
    
    func getAttestation() -> Data? {
        return defaults.data(forKey: "attestation")
    }
    
    func saveKeyId(keyId: Data) {
        defaults.set(keyId, forKey: "keyId")
    }
    
    func setAttested() {
        defaults.set(true, forKey: "attested")
    }
    
    func isAttested() -> Bool {
        return defaults.bool(forKey: "attested")
    }
    
    func saveChallenge(challenge: String) {
        defaults.set(challenge, forKey: "challenge")
    }
    
    func getChallenge() -> String? {
        return defaults.string(forKey: "challenge")
    }
}

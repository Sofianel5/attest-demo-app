//
//  AuthenticityManager.swift
//  ProofPix
//
//  Created by Sofiane Larbi on 5/17/24.
//

import Foundation

class AuthenticityManager {
    
//    private let appAttestManager = AppAttestManager.shared;
    private let persistenceManager = PersistenceController.shared;
    
    static let shared = AuthenticityManager();

    func setup() {
        print("AuthenticityManager.setup")
        AppAttestManager.shared.keyGen() {keyId in
            print("Got keyId: \(keyId)")
            let url = URL(string: "https://appattest-demo.onrender.com/challenge")!;
            var request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) {data,response,error in
                if let challenge = data {
                    print("Got challenge: \(challenge)")
                    AppAttestManager.shared.attestKey(challenge: challenge) { attestation in
                        print("Got attestation: \(attestation)")
                        self.persistenceManager.saveAttestation(attestation: attestation)
                        let url = URL(string: "https://appattest-demo.onrender.com/appattest")!;
                        let request = MultipartFormDataRequest(url: url)
                        request.addTextField(named: "attestaion", value: attestation.base64EncodedString())
                        URLSession.shared.dataTask(with: request, completionHandler: {data,response,error in
                            print("Callback...", String(describing: data))
                            if error != nil {
                                print("Error!")
                                return
                            }
                            PersistenceController.shared.setAttested()
                        }).resume()
                    }
                } else {
                    print("Challenge nil")
                }
            }
            task.resume()
        }
    }
    
    func setupIfNeeded() {
        if !persistenceManager.isAttested() { self.setup() } else { print("Attestation already derived") }
    }
    
}

//
//  AuthenticityManager.swift
//  ProofPix
//
//  Created by Sofiane Larbi on 5/17/24.
//

import Foundation
import NotificationBannerSwift

class AuthenticityManager {
    
//    private let appAttestManager = AppAttestManager.shared;
    private let persistenceManager = PersistenceController.shared;
    
    static let shared = AuthenticityManager();

    func setup() {
        print("AuthenticityManager.setup")
        AppAttestManager.shared.keyGen() {keyId in
            print("Got keyId: \(keyId)")
            let url = URL(string: "https://appattest-demo.onrender.com/challenge")!;
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) {data,response,error in
                if let challenge = data {
                    print("Got challenge: \(challenge)")
                    AppAttestManager.shared.attestKey(challenge: challenge) { attestation in
                        print("Got attestation: \(attestation)")
                        self.persistenceManager.saveAttestation(attestation: attestation)
                        // save challenge
                        let challenge_string = String(data: challenge, encoding: .utf8)!
                        self.persistenceManager.saveChallenge(challenge: challenge_string)
                        print("Challenge received: \(challenge_string)")
                        
                        let url = URL(string: "https://appattest-demo.onrender.com/appattest")!;
                        let request = MultipartFormDataRequest(url: url)
                        request.addTextField(named: "attestation_string", value: attestation.base64EncodedString())
                        request.addTextField(named: "raw_key_id", value: keyId)
                        request.addTextField(named: "challenge", value: challenge_string)
                        URLSession.shared.dataTask(with: request, completionHandler: {data,response,error in
                            print("Callback...", String(describing: data))
                            if error != nil {
                                print("Error!")
                                return
                            }
                            // TODO: do this on UI side otherwise everything crashes?
//                            let banner = NotificationBanner(title: "App Attested!", subtitle: "Your app has been attested as authentic.", style: .success)
//                            banner.show()
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

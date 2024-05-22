//
//  ApiManager.swift
//  AttestDemo
//
//  Created by Sofiane Larbi on 5/21/24.
//

import Foundation

class ApiManager {
    
    static let shared = ApiManager()
    
    struct Urls {
        static let SUBMIT_POST_URL: String = "https://appattest-demo.onrender.com/add"
    }
    
    private func sendPhotoToServer(_ image: Data, timestamp: String, signature: String, pubkey: String, latitude: String, longitude: String) {
        // Your code to send the image to the server
        // For example, using URLSession to send a POST request with the image data
        print("Sending photo to server...")

        guard let url = URL(string: Urls.SUBMIT_POST_URL) else { return }
        let request = MultipartFormDataRequest(url: url)
        request.addDataField(
            named: "photo_file",
            data: image,
            mimeType: "img/jpeg"
        )
        request.addTextField(named: "timestamp", value: timestamp)
        request.addTextField(named: "photo_signature", value: signature)
        request.addTextField(named: "poster_pubkey", value: pubkey)
        request.addTextField(named: "poster_attest_proof", value: "temp")
        request.addTextField(named: "location_lat", value: latitude)
        request.addTextField(named: "location_long", value: longitude)
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error uploading photo: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                print("Photo uploaded successfully!")
            }
        }

        task.resume()
    }

    
    func submitPhoto(jpegData: Data) {
        // Get location
        let (lat, lng): (Double, Double) = LocationManager.shared.getCurrentLocation()!
        
        // Get attestation
        let attestationString: String = PersistenceController.shared.getAttestation()!.base64EncodedString()
        
        // Get signature
        let jpegBase64String = jpegData.base64EncodedString()
        
        // Get timestamp
        let timestamp = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Set the desired date format
        let dateString = dateFormatter.string(from: timestamp)
        
        // Sign the base64 string
        if let signatureData = SecureEnclaveManager.shared.sign(message: jpegBase64String) {
            let signatureString = signatureData.base64EncodedString()
            print("Signed image saved")
            
            // Get pubkey
            do {
                if let pubkeyData = try SecureEnclaveManager.shared.exportPubKey() {
                    let pubkeyString = pubkeyData.base64EncodedString()
                    
                    // Send data
                    sendPhotoToServer(jpegData, timestamp: dateString, signature: signatureString, pubkey: pubkeyString, latitude: String(lat), longitude: String(lng))
                    
                } else {
                    print("Error: Public key data is nil")
                }
            } catch {
                print("Error extracting pubkey: \(error)")
            }
        } else {
            print("Error: Signature data is nil")
        }
    }
}

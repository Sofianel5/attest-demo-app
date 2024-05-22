//
//  ApiManager.swift
//  AttestDemo
//
//  Created by Sofiane Larbi on 5/21/24.
//

import Foundation
import SwiftData

class ApiManager {
    
    static let shared = ApiManager()
    
    struct Urls {
        static let SUBMIT_POST_URL: String = "https://appattest-demo.onrender.com/add"
        static let GET_POSTS_URL: String = "https://appattest-demo.onrender.com/images"
    }
    
    private func sendPhotoToServer(_ image: Data, timestamp: String, signature: String, attestation: String, pubkey: String, latitude: String, longitude: String) {
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
        request.addTextField(named: "poster_attest_proof", value: attestation)
        request.addTextField(named: "location_lat", value: latitude)
        request.addTextField(named: "location_long", value: longitude)
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error uploading photo: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                print("Photo uploaded successfully! Got: \(String(data: data!, encoding: .utf8) ?? "")")
            } else {
                print("Got response: \(String(describing: response))")
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
                    sendPhotoToServer(jpegData, timestamp: dateString, signature: signatureString, attestation: attestationString, pubkey: pubkeyString, latitude: String(lat), longitude: String(lng))
                    
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
    
    func getPosts(modelContext: ModelContext) {
        guard let url = URL(string: Urls.GET_POSTS_URL) else { return }
        var request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    print("Got response: \(String(data: data!, encoding: .utf8)!)")
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
                    let decodedData = try jsonDecoder.decode(ServerDataCollection.self, from: data!)
                    for obj in decodedData.post_data_objects {
                      let post = Post(from: obj)
                      modelContext.insert(post)
                    }
                } catch {
                  print("DownloadError.wrongDataFormat(error: \(error))")
                  return
                }
            } else {
              print("DownloadError.missingData. Got: \(response!)")
              return
            }
        }
        task.resume()
        
    }
}

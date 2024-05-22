//
//  PostBackend.swift
//  AttestDemo
//
//  Created by Kaylee George on 5/22/24.
//

import Foundation
import CoreLocation

// Location Manager

// sorry i put it here for now

func sendPhotoToServer(_ image: Data, timestamp: String, signature: String, pubkey: String, latitude: String, longitude: String) {
    // Your code to send the image to the server
    // For example, using URLSession to send a POST request with the image data
    print("Sending photo to server...")

    guard let url = URL(string: "https://appattest-demo.onrender.com/add") else { return }
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

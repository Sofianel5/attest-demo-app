//
//  PostView.swift
//  AttestDemo
//
//  Created by Sofiane Larbi on 5/19/24.
//

import SwiftUI
import CoreLocation

struct PostView: View {
    let post: Post
    @State private var address: String = "Loading address..."

    var body: some View {
        VStack(alignment: .leading) {
            // User Info
            HStack {
                AsyncImage(url: URL(string: post.photoURL)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                        .frame(width: 40, height: 40)
                }

                Text(post.posterPk)
                    .font(.headline)
                    .padding(.leading, 8)
                Text(address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding([.top, .horizontal])

            // Post Image
            AsyncImage(url: URL(string: post.photoURL)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
            } placeholder: {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 8)

            // Post Content
            Text(post.photoSig)
                .font(.body)
                .padding([.horizontal, .bottom])
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
        .onAppear {
            fetchAddress()
        }
    }
    
    func fetchAddress() {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: post.locationLat, longitude: post.locationLng)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Error in reverse geocoding: \(error.localizedDescription)")
                self.address = "Address not found"
                return
            }
            
            guard let placemark = placemarks?.first else {
                self.address = "Address not found"
                return
            }
            
            var addressString = ""
            if let subThoroughfare = placemark.subThoroughfare {
                addressString += subThoroughfare + " "
            }
            if let thoroughfare = placemark.thoroughfare {
                addressString += thoroughfare + ", "
            }
            if let locality = placemark.locality {
                addressString += locality + ", "
            }
            if let administrativeArea = placemark.administrativeArea {
                addressString += administrativeArea + " "
            }
            if let postalCode = placemark.postalCode {
                addressString += postalCode
            }
            
            self.address = addressString.isEmpty ? "Address not found" : addressString
        }
    }
}


#Preview {
    PostView(post: Post.example)
}

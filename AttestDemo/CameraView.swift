//
//  CameraView.swift
//  AttestDemo
//
//  Created by Sofiane Larbi on 5/20/24.
//

import CoreLocation
import SwiftUI
import AVFoundation

class CameraViewController: UIViewController, CLLocationManagerDelegate {
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    var onPhotoCaptured: ((Data, String, String, String, String, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Location services
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access back camera!")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if let captureSession = captureSession {
                captureSession.addInput(input)
                
                photoOutput = AVCapturePhotoOutput()
                if let photoOutput = photoOutput {
                    captureSession.addOutput(photoOutput)
                }
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                if let previewLayer = previewLayer {
                    previewLayer.videoGravity = .resizeAspectFill
                    view.layer.addSublayer(previewLayer)
                    previewLayer.frame = view.frame
                    
                    captureSession.startRunning()
                }
            }
        } catch {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        print("taking photo")
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
}

// Date to string
func dateToString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Set the desired date format
    let dateString = dateFormatter.string(from: date)
    return dateString
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        print("Photo captured")
        
        let timestamp = Date()
        let dateString = dateToString(date: timestamp)
        
        let latitude_raw = currentLocation?.coordinate.latitude
        let longitude_raw = currentLocation?.coordinate.longitude
        
        // Convert latitude and longitude to strings
        let latitude = latitude_raw != nil ? String(format: "%.6f", latitude_raw!) : "Unknown"
        let longitude = longitude_raw != nil ? String(format: "%.6f", longitude_raw!) : "Unknown"
        
        // Convert image data to image
        guard let image = UIImage(data: imageData) else { return }
        if let jpegData = image.jpegData(compressionQuality: 1.0) {
            let base64String = jpegData.base64EncodedString()
            
            // Sign the base64 string
            if let signatureData = SecureEnclaveManager.shared.sign(message: base64String) {
                let signatureString = signatureData.base64EncodedString()
                print("Signed image saved")
                
                // Get pubkey
                do {
                    if let pubkeyData = try SecureEnclaveManager.shared.exportPubKey() {
                        let pubkeyString = pubkeyData.base64EncodedString()
                        
                        // Send all data
                        onPhotoCaptured?(jpegData, dateString, signatureString, pubkeyString, latitude, longitude)
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
}


struct CameraView: UIViewControllerRepresentable {
    class Coordinator: NSObject {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        @objc func takePhoto() {
            print("taking photos")
            parent.cameraViewController.takePhoto()
        }
    }
    
    var cameraViewController: CameraViewController
    var onPhotoCaptured: ((Data, String, String, String, String, String) -> Void)
    
    init(cameraViewController: CameraViewController, onPhotoCaptured: @escaping ((Data, String, String, String, String, String) -> Void)) {
        self.cameraViewController = cameraViewController
        self.onPhotoCaptured = onPhotoCaptured
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = self.cameraViewController
        viewController.onPhotoCaptured = onPhotoCaptured
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}


struct FullScreenCameraView: View {
    @Environment(\.presentationMode) var presentationMode
    let cameraViewController = CameraViewController()
    
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
                presentationMode.wrappedValue.dismiss()
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                print("Photo uploaded successfully!")
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }

        task.resume()
    }
    
    var body: some View {
        ZStack {
            CameraView(cameraViewController: cameraViewController, onPhotoCaptured: {
                image, timestamp, signature, pubkey, latitude, longitude in sendPhotoToServer(image, timestamp: timestamp, signature: signature, pubkey: pubkey, latitude: latitude, longitude: longitude)
            })
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: {
                        // Dismiss the view
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    .padding(.top, 50)
                    
                    Spacer()
                }
                
                Spacer()
                
                Button(action: {
                    // Handle photo taking action
                    cameraViewController.takePhoto()
                    
                }) {
                    Circle()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.white)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 4)
                        )
                        .shadow(radius: 10)
                }
                .padding(.bottom, 30)
            }
        }
    }
}

struct FullScreenCameraView_Previews: PreviewProvider {
    static var previews: some View {
        FullScreenCameraView()
    }
}

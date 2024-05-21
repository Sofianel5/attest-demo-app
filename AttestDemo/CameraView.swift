//
//  CameraView.swift
//  AttestDemo
//
//  Created by Sofiane Larbi on 5/20/24.
//

import SwiftUI
import AVFoundation

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var onPhotoCaptured: ((Data) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        print("Photo captured")
        onPhotoCaptured?(imageData)
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
    var onPhotoCaptured: ((Data) -> Void)
    
    init(cameraViewController: CameraViewController, onPhotoCaptured: @escaping ( (Data) -> Void)) {
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
    
    func sendPhotoToServer(_ image: Data) {
        // Your code to send the image to the server
        // For example, using URLSession to send a POST request with the image data
        print("Sending photo to server...")

        guard let url = URL(string: "https://appattest-demo.onrender.com/upload") else { return }
        let request = MultipartFormDataRequest(url: url)
        request.addDataField(
            named: "image",
            data: image,
            mimeType: "img/jpeg"
        )
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
                image in sendPhotoToServer(image)
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

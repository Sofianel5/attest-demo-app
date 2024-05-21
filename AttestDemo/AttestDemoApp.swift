//
//  AttestDemoApp.swift
//  AttestDemo
//
//  Created by Sofiane Larbi on 5/19/24.
//

import SwiftUI
import SwiftData
import AVFoundation
import CoreLocation

@main
struct AttestDemoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Post.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    func requestLocationPermission() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("Camera access granted!")
            } else {
                print("Camera access denied :(")
            }
        }
    }
    
    func performSetupTasksIfNeeded() {
        requestLocationPermission()
        requestCameraPermission()
        AuthenticityManager.shared.setupIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: performSetupTasksIfNeeded)
        }
        .modelContainer(sharedModelContainer)
    }
}

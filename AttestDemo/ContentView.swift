//
//  ContentView.swift
//  AttestDemo
//
//  Created by Sofiane Larbi on 5/19/24.
//

import SwiftUI
import SwiftData
import NotificationBannerSwift

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    private let persistenceManager = PersistenceController.shared;
    @Query private var items: [Post]
    @State private var showCameraView = false

    var body: some View {
        NavigationSplitView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(items) { post in
                        PostView(post: post)
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .toolbar {
                ToolbarItem (placement: .navigationBarTrailing) {
                    Button(action: checkAttestation) {
                        Text("Check Attestation")
                    }
                }
            }
            .floatingButton(showCameraView: $showCameraView)
            .fullScreenCover(isPresented: $showCameraView) {
                FullScreenCameraView()
            }
        } detail: {
            Text("Select an item")
        }.onAppear {
            getItems()
        }.refreshable {
//            await refreshData();
            getItems()
        }
    }

    private func checkAttestation() {
        if (persistenceManager.isAttested()) {
            let subtitle = "Attested with attestation: " + (persistenceManager.getChallenge() ?? "");
            let banner = NotificationBanner(title: "Your app instance is attested!", subtitle: subtitle, style: .success)
            banner.show()
        }
    }
    
    private func getItems() {
        ApiManager.shared.getPosts(modelContext: modelContext)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Post.self, inMemory: true)
}

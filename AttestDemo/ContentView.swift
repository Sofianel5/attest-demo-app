//
//  ContentView.swift
//  AttestDemo
//
//  Created by Sofiane Larbi on 5/19/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
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
//            .toolbar {
//                ToolbarItem (placement: .navigationBarTrailing) {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
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

    private func addItem() {
        withAnimation {
            let newItem = Post.example
            modelContext.insert(newItem)
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

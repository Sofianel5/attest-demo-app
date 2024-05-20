//
//  FloatingCameraButton.swift
//  AttestDemo
//
//  Created by Sofiane Larbi on 5/20/24.
//

import Foundation
import SwiftUI

struct FloatingButton: ViewModifier {
    @Binding var showCameraView: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showCameraView = true
                    }) {
                        Image(systemName: "camera")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                    Spacer()
                }
            }
        }
    }
}

extension View {
    func floatingButton(showCameraView: Binding<Bool>) -> some View {
        self.modifier(FloatingButton(showCameraView: showCameraView))
    }
}

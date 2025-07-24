//
//  IDCapture.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 21/07/25.
//

import SwiftUI

struct IDCaptureView: View {
    @StateObject private var cameraService = CameraService()
        
        var body: some View {
            ZStack {
                CameraPreview(session: cameraService.session)
                    .ignoresSafeArea()
                IDCardOverlay()
                
                VStack {
                    Spacer()
                    Button(action: {
                        cameraService.capturePhoto()
                    }) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 72, height: 72)
                            .overlay(
                                Image(systemName: "camera")
                                    .font(.title)
                                    .foregroundColor(.white)
                            )
                            .padding(40)
                            .rotationEffect(.degrees(90))
                    }
                }
            }
            .onAppear {
                cameraService.configure()
            }
        }
}

#Preview {
    IDCaptureView()
}

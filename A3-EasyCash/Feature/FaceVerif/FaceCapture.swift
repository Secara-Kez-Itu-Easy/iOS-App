//
//  FaceCapture.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 24/07/25.
//

import SwiftUI

struct FaceCaptureView: View {
    @StateObject private var cameraService = CameraService()
    var router: AppRouter
    
    var body: some View {
        VStack(spacing: 60) {
            
            ZStack {
                if cameraService.isVerifying {
                    ProgressView(router: AppRouter())
                        .offset(y: -25)
                }
                else {
                    CameraPreview(session: cameraService.session)
                        .frame(width: 280, height: 280)
                        .scaleEffect(1.15)
                        .clipShape(Hexagon())
                    
                    if !cameraService.isCameraReady {
                        Image("SkeletonPerson")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 280, height: 280)
                    }
                }
            }
            .padding(.top, 96)
            
            Spacer()
            
            if !cameraService.isVerifying {
                Text("Face within the frame")
                    .font(.headline)
                
                Button(action: {
                    cameraService.capturePhoto {
                        router.push(.faceVerificationResult)
                    }
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
                }
            }
        }
        .navigationTitle("Face Verification")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            cameraService.configure(position: .front)
            cameraService.start()
        }
        .onDisappear {
            cameraService.stop()
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Image(systemName: "arrow.backward")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "headset")
                    .fontWeight(.black)
                    .opacity(0.2)
            }
        }
    }
}

#Preview {
    NavigationStack {
        FaceCaptureView(router: AppRouter())
    }
}

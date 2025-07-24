//
//  FaceCapture.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 24/07/25.
//

import SwiftUI

struct FaceCaptureVIew: View {
    @StateObject private var cameraService = CameraService()
    
    var body: some View {
        VStack(spacing: 60) {
            
            ZStack {
                if cameraService.isVerifying {
                    ProgressView()
                }
                else {
                    CameraPreview(session: cameraService.session)
                        .frame(width: 240, height: 240)
                        .clipShape(Hexagon())
                    
                    if !cameraService.isCameraReady {
                        Image("SkeletonPerson")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 240, height: 240)
                    }
                }
            }
            .padding(.top, 96)
            
            if !cameraService.isVerifying && !cameraService.isCameraReady {
                Text("Face within the frame")
                                .font(.headline)
            }
            
            Spacer()
        }
        .navigationTitle("Face Verification")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            cameraService.configure(position: .front)
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
        FaceCaptureVIew()
    }
}

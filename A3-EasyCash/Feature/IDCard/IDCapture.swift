//
//  IDCapture.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 21/07/25.
//

import SwiftUI

struct IDCaptureView: View {
    @EnvironmentObject var cameraService: CameraService
    @State private var photoCaptured: Bool = false
    var router: AppRouter
    
    var body: some View {
        ZStack {
            if !cameraService.isVerifying {
                CameraPreview(session: cameraService.session)
                    .mask(
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: 430, height: 240)
                            .rotationEffect(.degrees(90))
                    )
                    .ignoresSafeArea()
            }   else {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.secondary)
                        .frame(width: 430, height: 240)
                        .rotationEffect(.degrees(90))
                    
                    VerifyIDView()
                }
                .offset(x: 0, y: -12)
            }
            
            IDCardOverlay()
            
            VStack {
                Spacer()
                
                if !photoCaptured {
                    Button(action: {
                        photoCaptured = true
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
        }
        .onAppear {
            cameraService.configure(position: .back)
            cameraService.start()
        }
        .onDisappear {
            cameraService.stop()
        }
        .onChange(of: cameraService.isKTPProcessingDone) { _, done in
            if done {
                router.push(.idResult)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

//#Preview {
//    IDCaptureView(router: AppRouter())
//}

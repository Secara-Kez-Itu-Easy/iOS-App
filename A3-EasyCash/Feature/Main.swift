//
//  Main.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 21/07/25.
//

import SwiftUI

struct MainView: View {
    @State var router = AppRouter()
    @StateObject var cameraService = CameraService()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            IDUploadView(router: router)
                .navigationDestination(for: RouteEnum.self) { route in
                    switch route {
                    case .idUploadInfo:
                        IDUploadView(router: router)
                    case .idCapture:
                        IDCaptureView(router: router)
                            .environmentObject(cameraService)
                    case .idCaptureResult:
                        CompletedView(object: .idCard, router: router)
                    case .idInfo:
                        IDInfoView(router: router, ktpData: cameraService.visionKTPData)
                            .environmentObject(cameraService)
                    case .idResult:
                        KTPResultView(router: router)
                            .environmentObject(cameraService)
                    case .faceUploadInfo:
                        FaceUploadView(router: router)
                    case .faceVerification:
                        FaceCaptureView(router: router)
                            .environmentObject(cameraService)
                    case .faceVerificationResult:
                        CompletedView(object: .faceVerification, router: router)
                    }
                }
        }
    }
}

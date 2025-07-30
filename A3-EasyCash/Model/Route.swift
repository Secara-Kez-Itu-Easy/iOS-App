//
//  Route.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 24/07/25.
//

import Foundation

enum RouteEnum: Hashable {
    case idUploadInfo
    case idCapture
    case idCaptureResult
    case idResult
    case idInfo
    case faceUploadInfo
    case faceVerification
    case faceVerificationResult
}

import SwiftUI

@Observable
class AppRouter {
    var path: [RouteEnum] = []

    func push(_ route: RouteEnum) {
        path.append(route)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path.removeAll()
    }
}

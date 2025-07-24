//
//  CompletedViewModel.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 24/07/25.
//

import SwiftUI
import Combine

class CompletedViewModel: ObservableObject {
    enum CompletedObject {
        case idCard
        case faceVerification
    }

    @Published var title: String = ""
    @Published var messagePrefix: String = ""
    @Published var isRedirecting: Bool = false
    @Published var HelpIcon: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init(for object: CompletedObject) {
        switch object {
        case .idCard:
            title = "ID Card Verification"
            messagePrefix = "ID Card is completed."
            HelpIcon = true
        case .faceVerification:
            title = "Face Verification"
            messagePrefix = "Verification is completed."
            HelpIcon = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isRedirecting = true
        }
    }
}

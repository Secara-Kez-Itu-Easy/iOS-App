//
//  IDCardCompleted.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 21/07/25.
//

import SwiftUI

enum CompletedObject {
    case idCard
    case faceVerification

    var title: String {
        switch self {
        case .idCard: return "ID Card Verification"
        case .faceVerification: return "Face Verification"
        }
    }

    var messagePrefix: String {
        switch self {
        case .idCard: return "ID Card is completed."
        case .faceVerification: return "Verification is completed."
        }
    }

    var showHelpIcon: Bool {
        self == .idCard
    }

    var nextRoute: RouteEnum {
        switch self {
        case .idCard: return .faceVerification
        case .faceVerification: return .idUploadInfo
        }
    }
}

struct CompletedView: View {
    let object: CompletedObject
    var router: AppRouter

    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 290, height: 290)
                .foregroundStyle(.green)
                .padding(.bottom, 72)

            (
                Text(object.messagePrefix).bold() +
                Text(" The page will automatically redirect after 3 seconds")
            )
            .font(.subheadline)
            .padding(.horizontal, 32)
        }
        .navigationTitle(object.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "arrow.backward")
            }
            if object.showHelpIcon {
                ToolbarItem {
                    Image(systemName: "headset")
                        .fontWeight(.black)
                        .opacity(0.2)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if object == .faceVerification {
                    router.push(object.nextRoute)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CompletedView(object: .idCard, router: AppRouter())
    }
}

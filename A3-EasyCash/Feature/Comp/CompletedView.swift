//
//  IDCardCompleted.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 21/07/25.
//

import SwiftUI

struct CompletedView: View {
    @StateObject var viewModel: CompletedViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 290, height: 290)
                .foregroundStyle(.green)
                .padding(.bottom, 72)
            
            (
                Text(viewModel.messagePrefix).bold() +
                Text("The page will automatically redirect after 3 seconds")
            )
            .font(.subheadline)
            .padding(.horizontal, 32)
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "arrow.backward")
            }
            if viewModel.HelpIcon {
                ToolbarItem {
                    Image(systemName: "headset")
                        .fontWeight(.black)
                        .opacity(0.2)
                }
            }
        }
        .onChange(of: viewModel.isRedirecting) {
            if viewModel.isRedirecting {
                // Navigating later
            }
        }
    }
}

#Preview {
    NavigationStack {
        CompletedView(viewModel: CompletedViewModel(for: .faceVerification))
    }
}

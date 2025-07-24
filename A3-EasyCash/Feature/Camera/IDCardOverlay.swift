//
//  IDCardOverlay.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 21/07/25.
//


import SwiftUI

struct IDCardOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .mask(
                    Rectangle()
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: 430, height: 240)
                                .blendMode(.destinationOut)
                                .rotationEffect(.degrees(90))
                        )
                        .compositingGroup()
                )
            
            VStack {
                Text("Capture your ID Card")
                    .foregroundColor(.white)
                    .font(.headline)
                    .rotationEffect(.degrees(90))
                    .offset(x: 160, y: -90)
                
                Text("Make sure your photo clear and enough light is to increase the chance of passing")
                    .foregroundColor(.white)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .frame(width: 760)
                    .rotationEffect(.degrees(90))
                    .offset(x: -160, y: -90)
            }
            .offset(x: 0, y: 80)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        IDCardOverlay()
    }
}

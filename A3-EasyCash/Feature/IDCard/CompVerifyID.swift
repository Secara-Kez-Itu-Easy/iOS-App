//
//  ProgressView.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 24/07/25.
//

import SwiftUI

struct VerifyIDView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#D9D9D9"))
                .frame(width: 430, height: 240)
                .rotationEffect(.degrees(90))

            RoundedRectangle(cornerRadius: 16)
                .trim(from: 0, to: animate ? 1 : 0)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 430, height: 240)
                .rotationEffect(.degrees(90))
                .animation(.linear(duration: 3).repeatForever(autoreverses: false), value: animate)

            Text("Verifying, please wait…")
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .rotationEffect(.degrees(90))
        }
        .onAppear {
            animate = true
        }
    }
}

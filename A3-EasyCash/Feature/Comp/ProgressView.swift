//
//  ProgressView.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 24/07/25.
//

import SwiftUI

struct ProgressView: View {
    @State private var animate = false
    var router: AppRouter
    
    var body: some View {
        ZStack {
            Hexagon()
                .fill(Color(hex: "#D9D9D9"))
                .frame(width: 280, height: 280)
            
            Hexagon()
                .trim(from: 0, to: animate ? 1 : 0)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 320, height: 320)
                .animation(.linear(duration: 3).repeatForever(autoreverses: false), value: animate)
            
            // Center text
            Text("Verifying, please wait…")
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    ProgressView(router: AppRouter())
}

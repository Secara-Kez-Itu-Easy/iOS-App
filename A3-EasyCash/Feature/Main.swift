//
//  Main.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 21/07/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Button(action: {
                //Logic
            }) {
                Text("Start")
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    NavigationStack {
        MainView()
    }
}

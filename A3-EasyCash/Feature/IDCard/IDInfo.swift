//
//  IDInfo.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 21/07/25.
//

import SwiftUI

struct IDInfoView: View {
    @EnvironmentObject var cameraService: CameraService
    
    @State private var name: String
    @State private var idNumber: String
    @State private var motherName: String = ""
    
    var router: AppRouter
    
    var isFormValid: Bool {
        !name.isEmpty && !idNumber.isEmpty && !motherName.isEmpty
    }
    
    init(router: AppRouter, ktpData: VisionKTPData?) {
        self.router = router
        _name = State(initialValue: ktpData?.nama ?? "")
        _idNumber = State(initialValue: ktpData?.nik ?? "")
    }
    
    var body: some View {
        VStack (alignment: .leading){
            Text("Ensure the information below is accurate: once submitted, it cannot be edited.")
                .padding(12)
                .font(.caption)
                .frame(maxWidth: 300)
            
            VStack(spacing: 24) {
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("ID number", text: $idNumber)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Mother’s Maiden Name", text: $motherName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
            }
            .padding(.horizontal)
            
            Button(action: {
                router.push(.idCaptureResult)
            }) {
                Text("Next Step")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.green : Color.gray)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(!isFormValid)
            
            Spacer()
        }
        .navigationTitle("KTP Info")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "headset")
                    .fontWeight(.black)
                    .opacity(0.2)
            }
//            ToolbarItem(placement: .topBarLeading) {
//                Image(systemName: "arrow.left")
//            }
        }
    }
}

//#Preview {
//    NavigationStack {
//        IDInfoView(router: AppRouter())
//    }
//}

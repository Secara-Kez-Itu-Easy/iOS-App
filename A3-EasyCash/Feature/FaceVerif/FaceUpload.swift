//
//  FaceUpload.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 23/07/25.
//

import SwiftUI

struct FaceUploadView: View {
    var body: some View {
        VStack{
            Text("Face verification must be clear and unobstructed.")
                .font(.caption)
                .fontWeight(.medium)
            
//            Circle()
//                .foregroundStyle(.secondary)
//                .frame(width: 200)
//                .padding(.top, 32)
            //                .overlay(
            //                    Image("FaceVerif")
            //                        .resizable()
            //                        .scaledToFill()
            //                )
            Image("FaceVerif")
                .resizable()
                .scaledToFill()
                .frame(width: 210, height: 200)
                .clipShape(Circle())
                .padding(.top, 32)
                .shadow(radius: 2, x: 0, y: 5)
            
            Button {
                //
            } label: {
                Text("View Sample")
                    .font(.caption)
                    .fontWeight(.medium)
                    .tint(.green)
                    .padding(.top, 4)
            }
            
            Button(action: {
                //
            }) {
                Text("Take a Photo")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding()
            
            HStack {
                Circle()
                    .frame(width: 30)
                    .foregroundStyle(.green)
                    .opacity(0.5)
                    .overlay(
                        Image(systemName: "bolt.shield.fill")
                            .opacity(0.70)
                            .font(.title3)
                            .padding(8)
                    )
                    .padding(.leading, 12)
                
                Text("Diawasi oleh OJK, keamanan data di Easycash dijamin setara dengan keamanan data di bank.")
                    .font(.caption2)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 12)
                    .padding(.trailing, 12)
            }
            .background(Color.green.opacity(0.25))
            .cornerRadius(10)
            .padding(.horizontal)
            
            HStack(alignment: .center, spacing: 8) {
                Button {
                    //
                } label: {
                    Circle()
                        .frame(width: 24)
                        .foregroundStyle(.gray)
                        .padding(.leading, 12)
                }
                
                Text("By clicking this, you’re willing to share your data to Easycash, for data verification, any inquiries or any other matters")
                    .font(.caption2)
                    .fontWeight(.light)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Spacer()
            
        }
        .navigationTitle("Face Verification")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: "arrow.backward")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "headset")
                    .fontWeight(.black)
                    .opacity(0.2)
            }
        }
    }
}

#Preview {
    NavigationStack {
        FaceUploadView()
    }
}

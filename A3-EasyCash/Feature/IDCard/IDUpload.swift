import SwiftUI

struct IDUploadView: View {
    var router: AppRouter
    
    @State private var isConsentGiven: Bool = false

    var body: some View {
        VStack(spacing: 24) {

            Text("Upload a clear and complete photo of your KTP")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Image("IDPreview")
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .cornerRadius(12)
                .padding(48)

//            Button(action: {
//                // logic view sample
//            }) {
//                Text("View Sample")
//                    .font(.caption)
//                    .fontWeight(.medium)
//                    .foregroundColor(.green)
//            }

            Button(action: {
                router.push(.idCapture)
            }) {
                Text("Take a Photo")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isConsentGiven ? Color.green : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!isConsentGiven)
            .padding(.horizontal, 48)

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
            .padding(.horizontal, 48)

            HStack(alignment: .center, spacing: 8) {
                Button {
                    isConsentGiven.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                        
                        if isConsentGiven {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                .tint(.white)
                .padding(.leading, 12)
                .padding(.trailing, 12)
                .offset(x: -6)

                Text("By clicking this, you’re willing to share your data to Easycash, for data verification, any inquiries or any other matters")
                    .font(.caption2)
                    .fontWeight(.light)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 48)

            Spacer()
        }
        .padding()
        .navigationTitle("ID Card Verification")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar{
//            ToolbarItem(placement: .topBarLeading) {
//                Image(systemName: "arrow.backward")
//            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "headset")
                    .fontWeight(.black)
                    .opacity(0.2)
            }
        }
    }
}

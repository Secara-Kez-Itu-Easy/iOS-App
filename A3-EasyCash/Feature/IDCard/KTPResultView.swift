//
//  KTPResultView.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 29/07/25.
//

import SwiftUI

struct KTPResultView: View {
    @EnvironmentObject var cameraService: CameraService
    @State private var name: String = ""
    @State private var nik: String = ""
    @State private var kelurahan: String = ""
    @State private var kecamatan: String = ""
    @State private var authenticity: String = ""
    @State private var confidence: String = ""
    @State private var jenisKelamin: String = ""
    @State private var rtRw: String = ""
    @State private var tempatLahir: String = ""
    @State private var tanggalLahir: String = ""
    @State private var agama: String = ""
    @State private var statusPerkawinan: String = ""
    @State private var pekerjaan: String = ""
    @State private var kewarganegaraan: String = ""
    @State private var golDarah: String = ""

    let router: AppRouter

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                if let image = cameraService.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 240)
                        .cornerRadius(24)
                        .rotationEffect(.degrees(-90))
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                if !authenticity.isEmpty {
                    GroupBox(label: Text("Document Authenticity Analysis").font(.headline)) {
                        VStack(alignment: .leading, spacing: 12) {
                            InfoRow(label: "Authenticity", value: authenticity)
                            InfoRow(label: "Confidence", value: confidence)
                        }
                        .padding(.top, 8)
                    }
                }

                GroupBox(label: Text("ID Card Information").font(.headline)) {
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(label: "Full Name", value: name)
                        InfoRow(label: "ID Number", value: nik)
                        InfoRow(label: "Sub-district", value: kelurahan)
                        InfoRow(label: "District", value: kecamatan)
                        InfoRow(label: "Gender", value: jenisKelamin)
                        InfoRow(label: "RT/RW", value: rtRw)
                        InfoRow(label: "Place of Birth", value: tempatLahir)
                        InfoRow(label: "Date of Birth", value: tanggalLahir)
                        InfoRow(label: "Religion", value: agama)
                        InfoRow(label: "Marital Status", value: statusPerkawinan)
                        InfoRow(label: "Occupation", value: pekerjaan)
                        InfoRow(label: "Nationality", value: kewarganegaraan)
                        InfoRow(label: "Blood Type", value: golDarah)
                    }
                    .padding(.top, 8)
                }

                Spacer()

                Button(action: {
                    router.push(.idCaptureResult)
                }) {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .onAppear {
            if let data = cameraService.visionKTPData {
                name = data.nama
                nik = data.nik
                kelurahan = data.kelurahan
                kecamatan = data.kecamatan
                jenisKelamin = data.jenisKelamin
                rtRw = data.rtRw
                tempatLahir = data.tempatLahir
                tanggalLahir = data.tanggalLahir
                agama = data.agama
                statusPerkawinan = data.status
                pekerjaan = data.pekerjaan
                kewarganegaraan = data.kewarganegaraan
                golDarah = data.golDarah
            }
            if let result = cameraService.analysisResult {
                authenticity = result.status.capitalized
                confidence = String(format: "%.2f%%", result.confidencePercent)
            }
        }
        .onChange(of: cameraService.visionKTPData) { _, newValue in
            guard let data = newValue else { return }
            name = data.nama
            nik = data.nik
            kelurahan = data.kelurahan
            kecamatan = data.kecamatan
            jenisKelamin = data.jenisKelamin
            rtRw = data.rtRw
            tempatLahir = data.tempatLahir
            tanggalLahir = data.tanggalLahir
            agama = data.agama
            statusPerkawinan = data.status
            pekerjaan = data.pekerjaan
            kewarganegaraan = data.kewarganegaraan
            golDarah = data.golDarah
        }
        .onChange(of: cameraService.analysisResult) { _, newValue in
            if let result = newValue {
                authenticity = result.status.capitalized
                confidence = String(format: "%.2f%%", result.confidencePercent)
            }
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
        .navigationBarBackButtonHidden(true)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

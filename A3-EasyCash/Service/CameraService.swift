//
//  CameraService.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 21/07/25.
//

import AVFoundation
import UIKit
import Alamofire
import Photos
import Vision

class CameraService: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var currentInput: AVCaptureDeviceInput?
    
    @Published var isCameraReady: Bool = false
    @Published var isVerifying: Bool = false
    @Published var capturedImageData: Data?
    @Published var capturedImage: UIImage?
    @Published var analysisResult: AuthenticityResponse?
    @Published var visionKTPData: VisionKTPData?
    @Published var isKTPProcessingDone: Bool = false
    
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    func configure(position: CameraPreference = .front) {
        checkCameraPermission { granted in
            guard granted else {
                print("Camera permission not granted.")
                return
            }
            
            self.sessionQueue.async {
                self.session.beginConfiguration()
                self.session.sessionPreset = .photo
                
                if let input = self.currentInput {
                    self.session.removeInput(input)
                }
                
                let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                     for: .video,
                                                     position: position == .front ? .front : .back)
                
                guard let camera = device,
                      let input = try? AVCaptureDeviceInput(device: camera),
                      self.session.canAddInput(input),
                      self.session.canAddOutput(self.output) else {
                    self.session.commitConfiguration()
                    return
                }
                
                self.session.addInput(input)
                self.session.addOutput(self.output)
                if let connection = self.output.connection(with: .video) {
                    if #available(iOS 17.0, *) {
                        if connection.isVideoRotationAngleSupported(90) {
                            connection.videoRotationAngle = 90
                        }
                    } else if connection.isVideoOrientationSupported {
                        connection.videoOrientation = .landscapeRight
                    }
                }
                self.currentInput = input
                
                self.session.commitConfiguration()
                
                DispatchQueue.main.async {
                    self.isCameraReady = true
                }
                
                self.session.startRunning()
            }
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        isVerifying = true
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func start() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stop() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            print("Photo captured with size: \(data.count) bytes")
            if let croppedImage = self.cropToOverlay(image),
               let croppedData = croppedImage.jpegData(compressionQuality: 0.8) {
                self.capturedImage = croppedImage
                self.capturedImageData = croppedData
//                self.saveImageToGallery(image)
                self.saveImageToGallery(croppedImage)
                uploadKTPImage(croppedData)
            } else {
                self.capturedImage = image
                self.capturedImageData = data
                uploadKTPImage(data)
            }
            
            self.stop()
        }
    }
    
    private func cropToOverlay(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let semaphore = DispatchSemaphore(value: 0)
        var finalImage: UIImage?

        let request = VNDetectRectanglesRequest { request, error in
            defer { semaphore.signal() }

            guard let result = request.results?.first as? VNRectangleObservation else {
                print("No KTP detected")
                return
            }

            let imageWidth = CGFloat(cgImage.width)
            let imageHeight = CGFloat(cgImage.height)

            let boundingBox = result.boundingBox
            let cropRect = CGRect(
                x: boundingBox.origin.x * imageWidth,
                y: (1 - boundingBox.origin.y - boundingBox.height) * imageHeight,
                width: boundingBox.width * imageWidth,
                height: boundingBox.height * imageHeight
            )

            let padding: CGFloat = 40.0
            let expandedRect = cropRect.insetBy(dx: -padding, dy: -padding)
            let imageRect = CGRect(origin: .zero, size: CGSize(width: imageWidth, height: imageHeight))
            let finalCropRect = expandedRect.intersection(imageRect)

            print("Detected KTP at: \(finalCropRect)")

            if let croppedCGImage = cgImage.cropping(to: finalCropRect) {
                finalImage = UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)

                let textRequest = VNRecognizeTextRequest { (request, error) in
                    defer { semaphore.signal() }
                    guard let observations = request.results as? [VNRecognizedTextObservation] else {
                        print("❌ No text found")
                        return
                    }

                    let recognizedTexts = observations.compactMap { $0.topCandidates(1).first?.string }
                    let parsedData = self.parseKTP(from: recognizedTexts)
                    print("📄 Recognized text:")
                    recognizedTexts.forEach { print($0) }
                    
                    print("📄 Parsed KTP Data:")
                    for (key, value) in parsedData {
                        print("\(key): \(value)")
                    }
                    
                    let rawNIK = parsedData["NIK"] ?? ""
                    let nik = rawNIK.firstMatch(of: #"(?<!\d)\d{16}(?!\d)"#) ?? ""

                    let tempatTglLahir = parsedData["Tempat/Tgl Lahir"] ?? ""
                    let tempatLahir = tempatTglLahir.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    let tanggalLahir = tempatTglLahir.components(separatedBy: ",").dropFirst().joined(separator: ",").trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    let ktp = VisionKTPData(
                        nik: nik,
                        nama: parsedData["Nama"] ?? "",
                        jenisKelamin: parsedData["Jenis Kelamin"] ?? "",
                        rtRw: parsedData["RT/RW"] ?? "",
                        kelurahan: parsedData["Kel/Desa"] ?? "",
                        kecamatan: parsedData["Kecamatan"] ?? "",
                        tempatLahir: tempatLahir,
                        tanggalLahir: tanggalLahir,
                        agama: parsedData["Agama"] ?? "",
                        status: parsedData["Status Perkawinan"] ?? "",
                        pekerjaan: parsedData["Pekerjaan"] ?? "",
                        kewarganegaraan: parsedData["Kewarganegaraan"] ?? "",
                        golDarah: parsedData["Gol. Darah"] ?? ""
                    )

                    DispatchQueue.main.async {
                        if parsedData.isEmpty {
                            print("⚠️ Parsed data is empty. Assigning fallback dummy data.")
                            self.visionKTPData = VisionKTPData(
                                nik: "1234567890123456",
                                nama: "Contoh Nama",
                                jenisKelamin: "LAKI-LAKI",
                                rtRw: "001/002",
                                kelurahan: "PASIR PUTIH",
                                kecamatan: "SAWANGAN",
                                tempatLahir: "JAKARTA",
                                tanggalLahir: "01-01-1990",
                                agama: "Islam",
                                status: "Belum Kawin",
                                pekerjaan: "Pelajar",
                                kewarganegaraan: "WNI",
                                golDarah: "O"
                            )
                        } else {
                            print("✅ Assigned visionKTPData:", ktp)
                            print("📌 Assigned in CameraService:", ObjectIdentifier(self))
                            self.visionKTPData = ktp
                        }
                        self.checkIfProcessingComplete()
                    }
                }

                textRequest.recognitionLevel = .accurate
                textRequest.usesLanguageCorrection = true

                let textRequestHandler = VNImageRequestHandler(cgImage: croppedCGImage, options: [:])
                do {
                    try textRequestHandler.perform([textRequest])
                } catch {
                    print("❌ OCR error: \(error)")
                }
            }
        }

        request.minimumConfidence = 0.6
        request.minimumAspectRatio = 0.4
        request.maximumObservations = 1

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("❌ Vision error: \(error)")
                semaphore.signal()
            }
        }

        // Wait for the Vision request to complete
        semaphore.wait()
        return finalImage
    }
    
    private func uploadKTPImage(_ data: Data) {
        print("📤 Uploading image to server...")

        let url = URL(string: "http://192.168.93.101:8888/api/authenticity")!

        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: "file", fileName: "file.jpg", mimeType: "image/jpeg")
            },
            to: url
        )
        .validate()
        .responseData { response in
            switch response.result {
            case .success(let data):
                print("📦 Raw response data:")
                if let rawString = String(data: data, encoding: .utf8) {
                    print(rawString)
                }

                struct Wrapper: Codable {
                    let data: AuthenticityContainer
                }
                struct AuthenticityContainer: Codable {
                    let authenticity: AuthenticityResponse
                }

                do {
                    let decoded = try JSONDecoder().decode(Wrapper.self, from: data)
                    DispatchQueue.main.async {
                        self.analysisResult = decoded.data.authenticity
                        self.checkIfProcessingComplete()
                    }
                    print("✅ Decoded successfully: \(decoded)")
                } catch {
                    print("❌ Decoding error: \(error)")
                }

            case .failure(let error):
                print("❌ Request failed: \(error)")
            }
        }
    }
    
    private func saveImageToGallery(_ image: UIImage) {
        // Rotasi 90 derajat searah jarum jam
        let rotatedImage = rotateImage90Degrees(image)

        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                UIImageWriteToSavedPhotosAlbum(rotatedImage, nil, nil, nil)
                print("✅ Gambar yang sudah diputar disimpan ke galeri.")
            } else {
                print("❌ Akses ke galeri tidak diberikan.")
            }
        }
    }

    private func rotateImage90Degrees(_ image: UIImage) -> UIImage {
        let size = CGSize(width: image.size.height, height: image.size.width)

        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return image
        }

        // Pindahkan origin ke tengah canvas
        context.translateBy(x: size.width / 2, y: size.height / 2)
        // Rotasi 90 derajat (dalam radian)
        context.rotate(by: -.pi / 2)
        // Gambar ulang gambar pada posisi yang sesuai
        image.draw(in: CGRect(x: -image.size.width / 2,
                              y: -image.size.height / 2,
                              width: image.size.width,
                              height: image.size.height))

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()

        return rotatedImage
    }
    
    private func parseKTP(from lines: [String]) -> [String: String] {
        var result: [String: String] = [:]
        var bufferKey: String?
        var bufferValue: String = ""

        func flushBuffer() {
            if let key = bufferKey, !bufferValue.isEmpty {
                result[key] = bufferValue.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            bufferKey = nil
            bufferValue = ""
        }

        for line in lines {
            // Sanitasi setiap baris: hanya karakter yang diizinkan (kecuali - dan / tetap diizinkan)
            let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789:/,-. ")
            let cleanedLine = line.unicodeScalars.filter { allowedCharacters.contains($0) }.map { String($0) }.joined()
            let trimmedLine = cleanedLine.trimmingCharacters(in: .whitespacesAndNewlines)

            // Jika ini baris nilai (angka) dan sedang buffer NIK → simpan langsung
            if bufferKey == "NIK", trimmedLine.range(of: #"^\d{16}$"#, options: .regularExpression) != nil {
                bufferValue = trimmedLine
                flushBuffer()
                continue
            }

            // Deteksi key
            if trimmedLine.lowercased().contains("nik") {
                flushBuffer()
                bufferKey = "NIK"
                if let nikValue = trimmedLine.components(separatedBy: ":").last?
                    .trimmingCharacters(in: CharacterSet(charactersIn: ": ").union(.whitespaces)),
                    nikValue.range(of: #"^\d{16}$"#, options: .regularExpression) != nil {
                    bufferValue = nikValue
                    flushBuffer()
                }
            } else if trimmedLine.lowercased().contains("nama") {
                flushBuffer()
                if trimmedLine.contains(":") {
                    let components = trimmedLine.components(separatedBy: ":")
                    if components.count > 1 {
                        result["Nama"] = components[1].trimmingCharacters(in: CharacterSet(charactersIn: ": ").union(.whitespacesAndNewlines))
                    }
                } else {
                    bufferKey = "Nama"
                }
            } else if trimmedLine.lowercased().contains("tempat") {
                flushBuffer()
                result["Tempat/Tgl Lahir"] = trimmedLine.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces)
            } else if trimmedLine.lowercased().contains("jenis kelamin") {
                flushBuffer()
                if trimmedLine.contains(":") {
                    let components = trimmedLine.components(separatedBy: ":")
                    if components.count > 1 {
                        result["Jenis Kelamin"] = components[1].trimmingCharacters(in: CharacterSet(charactersIn: ": ").union(.whitespacesAndNewlines))
                    }
                } else {
                    bufferKey = "Jenis Kelamin"
                }
            } else if trimmedLine.lowercased().contains("gol") {
                flushBuffer()
                result["Gol. Darah"] = trimmedLine.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces)
            } else if trimmedLine.lowercased().contains("alamat") {
                flushBuffer()
                bufferKey = "Alamat"
            } else if trimmedLine.lowercased().contains("rt/rw") {
                flushBuffer()
                if trimmedLine.contains(":") {
                    let components = trimmedLine.components(separatedBy: ":")
                    if components.count > 1 {
                        result["RT/RW"] = components[1].trimmingCharacters(in: CharacterSet(charactersIn: ": ").union(.whitespacesAndNewlines))
                    }
                } else {
                    bufferKey = "RT/RW"
                }
            } else if trimmedLine.lowercased().contains("kel") {
                flushBuffer()
                bufferKey = "Kel/Desa"
            } else if trimmedLine.lowercased().contains("kecamatan") {
                flushBuffer()
                bufferKey = "Kecamatan"
            } else if trimmedLine.lowercased().contains("agama") {
                flushBuffer()
                result["Agama"] = trimmedLine.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces)
            } else if trimmedLine.lowercased().contains("status") {
                flushBuffer()
                result["Status Perkawinan"] = trimmedLine.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces)
            } else if trimmedLine.lowercased().contains("pekerjaan") {
                flushBuffer()
                if trimmedLine.contains(":") {
                    let components = trimmedLine.components(separatedBy: ":")
                    if components.count > 1 {
                        result["Pekerjaan"] = components[1].trimmingCharacters(in: CharacterSet(charactersIn: ": ").union(.whitespacesAndNewlines))
                    }
                } else {
                    bufferKey = "Pekerjaan"
                }
            } else if trimmedLine.lowercased().contains("kewarganegaraan") {
                flushBuffer()
                result["Kewarganegaraan"] = trimmedLine.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces)
            } else if trimmedLine.lowercased().contains("berlaku") {
                flushBuffer()
                bufferKey = "Berlaku Hingga"
            } else if trimmedLine.range(of: #"^\d{2}-\d{2}-\d{4}$"#, options: .regularExpression) != nil {
                result["Tanggal Cetak"] = trimmedLine
            } else {
                // Baris nilai lanjutan
                bufferValue += (bufferValue.isEmpty ? "" : " ") + trimmedLine
            }
        }

        flushBuffer()
        for (key, value) in result {
            result[key] = value.replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return result
    }
    
    private func checkIfProcessingComplete() {
        if visionKTPData != nil && analysisResult != nil {
            isKTPProcessingDone = true
        }
    }
}

enum CameraPreference {
    case front
    case back
}

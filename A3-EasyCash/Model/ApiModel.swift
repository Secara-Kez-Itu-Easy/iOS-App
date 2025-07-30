//
//  ApiModel.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 28/07/25.
//

struct AnalyzeResponse: Codable {
    let status: String
    let code: Int
    let message: String
    let data: KTPData
}

struct KTPData: Codable {
    let authenticity: AuthenticityResponse
}

struct AuthenticityResponse: Codable, Equatable {
    let confidencePercent: Double
    let status: String

    enum CodingKeys: String, CodingKey {
        case confidencePercent = "confidence_percent"
        case status
    }
}

struct KTPInfo: Codable, Hashable {
    let nik: String?
    let nama: String?
    let tempat_lahir: String?
    let tanggal_lahir: String?
    let jenis_kelamin: String?
    let provinsi: String?
    let kabupaten: String?
    let alamat: String?
    let rt_rw: String?
    let kelurahan: String?
    let kecamatan: String?
    let agama: String?
    let status_perkawinan: String?
    let pekerjaan: String?
    let kewarganegaraan: String?
    let nik_validation_details: NIKValidationDetails?
}

struct NIKValidationDetails: Codable, Hashable {
    let is_valid: Bool?
    let error_reason: String?
    let details: NIKDetails
}

struct NIKDetails: Codable, Hashable {
    let age: Int?
    let date_of_birth: String?
    let district: String?
    let gender: String?
    let province: String?
    let subdivision: String?
}

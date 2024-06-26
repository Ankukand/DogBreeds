//
//  Model.swift
//  StatusNeoProject_Anku
//
//  Created by Anku on 26/06/24.
//

import Foundation

struct LikedImage: Codable {
    let breed: String
    let url: String
}
struct DogBreedsResponse: Decodable {
    let message: [String: [String]]
    let status: String
}

struct DogImagesResponse: Decodable {
    let message: [String]
    let status: String
}

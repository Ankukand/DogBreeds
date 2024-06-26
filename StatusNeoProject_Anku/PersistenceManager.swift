//
//  PersistenceManager.swift
//  StatusNeoProject_Anku
//
//  Created by Anku on 26/06/24.
//

import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    
    func saveLikedImage(likedImage: LikedImage) {
        var likedImages = fetchLikedImages()
        likedImages.append(likedImage)
        if let data = try? JSONEncoder().encode(likedImages) {
            UserDefaults.standard.set(data, forKey: "likedImages")
        }
    }
    
    func removeLikedImage(likedImage: LikedImage) {
        var likedImages = fetchLikedImages()
        likedImages.removeAll { $0.breed == likedImage.breed && $0.url == likedImage.url }
        if let data = try? JSONEncoder().encode(likedImages) {
            UserDefaults.standard.set(data, forKey: "likedImages")
        }
    }
    
    func fetchLikedImages() -> [LikedImage] {
        if let data = UserDefaults.standard.data(forKey: "likedImages"),
           let likedImages = try? JSONDecoder().decode([LikedImage].self, from: data) {
            return likedImages
        }
        return []
    }
}

//
//  DogImagesViewController.swift
//  StatusNeoProject_Anku
//
//  Created by Anku on 26/06/24.
//

import UIKit
import SDWebImage
import Alamofire

class DogImagesViewController: UICollectionViewController {
    private var images = [String]()
    private var breed: String
    private var likedImages = Set<String>()
    
    init(breed: String) {
        self.breed = breed
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = breed.capitalized
        collectionView.register(DogImageCell.self, forCellWithReuseIdentifier: "dogImageCell")
        loadLikedImages()
        fetchImages()
        NotificationCenter.default.addObserver(self, selector: #selector(handleLikedImagesUpdate(notification:)), name: .didUpdateLikedImages, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didUpdateLikedImages, object: nil)
    }
    
    private func loadLikedImages() {
        let allLikedImages = PersistenceManager.shared.fetchLikedImages()
        likedImages = Set(allLikedImages.filter { $0.breed == breed }.map { $0.url })
    }
    
    private func fetchImages() {
        NetworkManager.shared.fetchImages(for: breed) { [weak self] result in
            switch result {
            case .success(let images):
                self?.images = images
                self?.collectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc private func handleLikedImagesUpdate(notification: Notification) {
        if let likedImage = notification.userInfo?["likedImage"] as? LikedImage, likedImage.breed == breed {
            likedImages.remove(likedImage.url)
            collectionView.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dogImageCell", for: indexPath) as! DogImageCell
        let imageUrl = images[indexPath.row]
        cell.imageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
        cell.likeButton.isSelected = likedImages.contains(imageUrl)
        cell.likeButtonAction = { [weak self] in
            guard let self = self else { return }
            if cell.likeButton.isSelected {
                self.likedImages.insert(imageUrl)
                let likedImage = LikedImage(breed: self.breed, url: imageUrl)
                PersistenceManager.shared.saveLikedImage(likedImage: likedImage)
            } else {
                self.likedImages.remove(imageUrl)
                PersistenceManager.shared.removeLikedImage(likedImage: LikedImage(breed: self.breed, url: imageUrl))
            }
        }
        return cell
    }
}



class DogImageCell: UICollectionViewCell {
    let imageView = UIImageView()
    let likeButton = UIButton(type: .custom)
    var likeButtonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(likeButton)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            likeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
        contentView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func didTapLikeButton() {
        toggleLike()
    }
    
    @objc private func didTapCell() {
        toggleLike()
    }
    
    private func toggleLike() {
        likeButton.isSelected.toggle()
        likeButtonAction?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

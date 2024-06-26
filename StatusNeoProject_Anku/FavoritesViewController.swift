//
//  FavoritesViewController.swift
//  StatusNeoProject_Anku
//
//  Created by Anku on 26/06/24.
//

import UIKit
import SDWebImage

class FavoritesViewController: UITableViewController {
    private var likedImages = [LikedImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        tableView.register(FavoriteImageCell.self, forCellReuseIdentifier: "favoriteCell")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        loadLikedImages()
    }
    private func loadLikedImages() {
        likedImages = PersistenceManager.shared.fetchLikedImages()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedImages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoriteImageCell
        let likedImage = likedImages[indexPath.row]
        cell.configure(with: likedImage)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let likedImage = likedImages[indexPath.row]
            PersistenceManager.shared.removeLikedImage(likedImage: likedImage)
            likedImages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            NotificationCenter.default.post(name: .didUpdateLikedImages, object: nil, userInfo: ["likedImage": likedImage])
        }
    }
}

class FavoriteImageCell: UITableViewCell {
    let dogImageView = UIImageView()
    let breedLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(dogImageView)
        contentView.addSubview(breedLabel)
        
        dogImageView.translatesAutoresizingMaskIntoConstraints = false
        breedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dogImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            dogImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dogImageView.widthAnchor.constraint(equalToConstant: 50),
            dogImageView.heightAnchor.constraint(equalToConstant: 50),
            
            breedLabel.leadingAnchor.constraint(equalTo: dogImageView.trailingAnchor, constant: 15),
            breedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            breedLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        dogImageView.contentMode = .scaleAspectFill
        dogImageView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with likedImage: LikedImage) {
        breedLabel.text = likedImage.breed.capitalized
        dogImageView.sd_setImage(with: URL(string: likedImage.url), completed: nil)
    }
}

extension Notification.Name {
    static let didUpdateLikedImages = Notification.Name("didUpdateLikedImages")
}

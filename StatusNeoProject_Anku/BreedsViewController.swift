//
//  BreedsViewController.swift
//  StatusNeoProject_Anku
//
//  Created by Anku on 26/06/24.
//
import UIKit
import Alamofire

class BreedsViewController: UITableViewController {
    private var breeds = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Breeds"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "breedCell")
        fetchBreeds()
    }
    
    private func fetchBreeds() {
        NetworkManager.shared.fetchBreeds { [weak self] result in
            switch result {
            case .success(let breeds):
                self?.breeds = breeds
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breeds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "breedCell", for: indexPath)
        cell.textLabel?.text = breeds[indexPath.row].capitalized
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let breed = breeds[indexPath.row]
        let dogImagesVC = DogImagesViewController(breed: breed)
        navigationController?.pushViewController(dogImagesVC, animated: true)
    }
}

//
//  NetworkManager.swift
//  StatusNeoProject_Anku
//
//  Created by Anku on 26/06/24.
//

import Foundation
import Alamofire
import Reachability
import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://dog.ceo/api"
    private var loader: UIAlertController?
    private let reachability = try! Reachability()
    
    private init() {
        setupReachability()
    }
    
    private func setupReachability() {
        reachability.whenReachable = { [weak self] _ in
            // Internet connection is available
            print("Internet connection is available")
            // You can perform any necessary actions when internet is reachable
        }
        
        reachability.whenUnreachable = { [weak self] _ in
            // Internet connection is unavailable
            print("Internet connection is unavailable")
            self?.showAlert(title: "No Internet Connection", message: "Please check your internet connection and try again.")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    private func showAlert(title: String, message: String) {
        guard let viewController = getRootViewController() else {
            print("Unable to find root view controller to present alert.")
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    deinit {
        reachability.stopNotifier()
    }
    
    func showLoader(in viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
        viewController.present(alert, animated: false, completion: nil)
        loader = alert
    }
    
    func hideLoader() {
        loader?.dismiss(animated: false, completion: nil)
        loader = nil
    }
    
    func fetchBreeds(completion: @escaping (Result<[String], Error>) -> Void) {
        guard reachability.connection != .unavailable else {
            self.showAlert(title: "Alert", message: "No internet connection.")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No internet connection."])))
            return
        }
        
        let url = "\(baseURL)/breeds/list/all"
        
        guard let viewController = getRootViewController() else {
            self.showAlert(title: "Alert", message: "Unable to fetch data.")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch data."])))
            return
        }
        showLoader(in: viewController)
        
        AF.request(url).responseDecodable(of: DogBreedsResponse.self) { [weak self] response in
            self?.hideLoader()
            
            switch response.result {
            case .success(let data):
                let breeds = Array(data.message.keys)
                completion(.success(breeds))
            case .failure(let error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    func fetchImages(for breed: String, completion: @escaping (Result<[String], Error>) -> Void) {
        guard reachability.connection != .unavailable else {
            self.showAlert(title: "Alert", message: "No internet connection.")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No internet connection."])))
            return
        }
        
        let url = "\(baseURL)/breed/\(breed)/images"
        
        guard let viewController = getRootViewController() else {
            self.showAlert(title: "Alert", message: "Unable to fetch data.")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch data."])))
            return
        }
        
        showLoader(in: viewController)
        
        AF.request(url).responseDecodable(of: DogImagesResponse.self) { [weak self] response in
            self?.hideLoader()
            
            switch response.result {
            case .success(let data):
                completion(.success(data.message))
            case .failure(let error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }
}


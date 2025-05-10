//
//  NetworkManager.swift
//  PokeApp
//
//  Created by Fahim Rahman on 9/5/25.
//

import Foundation
import Alamofire

final class NetworkManager {
    
    static let shared = NetworkManager()
    private init() { }

    // MARK: - raw data request [No Model]
    func requestRaw(url: String, method: HTTPMethod, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, completion: @escaping (Result<Data, Error>) -> Void) {
        
        var request: DataRequest

        if let parameters = parameters {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
                completion(.failure(NSError(domain: "Invalid JSON", code: 0)))
                return
            }
            guard var urlRequest = try? URLRequest(url: url, method: method, headers: headers) else {
                completion(.failure(NSError(domain: "Invalid URL", code: 0)))
                return
            }
            urlRequest.httpBody = jsonData
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request = AF.request(urlRequest)
        } else {
            request = AF.request(url, method: method, headers: headers)
        }

        request.validate().responseData { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

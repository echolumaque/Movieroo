//
//  NetworkManager.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit

class NetworkManagerClass {
    private let cache: NSCache<NSString, UIImage>
    
    init() {
        cache = NSCache<NSString, UIImage>()
    }
    
    func downloadImage(from urlString: String) async -> UIImage? {
        let cacheKey = NSString(string: urlString)
        if let cachedImage = cache.object(forKey: cacheKey) { return cachedImage }
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            
            cache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            return nil
        }
    }
    
    func baseNetworkCall<Result: Codable>(for constructedUrl: String) async throws(NetworkingError) -> Result {
        guard let accessToken: String = try? Configuration.value(for: "API_KEY") else {
            throw .requestFailed(innerError: URLError(.cancelled))
        }
        guard let endPoint = URL(string: constructedUrl) else {
            throw .requestFailed(innerError: URLError(.badURL))
        }
        
        do {
            var networkRequest = URLRequest(url: endPoint)
            networkRequest.httpMethod = "GET"
            networkRequest.timeoutInterval = 10
            networkRequest.allHTTPHeaderFields = [
                "accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            
            let (data, response) = try await URLSession.shared.data(for: networkRequest)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                throw NetworkingError.invalidStatusCode(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            
            let parsedData = try data.decode(to: Result.self)
            return parsedData
        } catch let error as DecodingError {
            throw .decodingFailed(innerError: error)
        } catch let error as EncodingError {
            throw .encodingFailed(innerError: error)
        } catch let error as URLError {
            throw .requestFailed(innerError: error)
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw .otherError(innerError: error)
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func downloadImage(from urlString: String) async -> UIImage? {
        let cacheKey = NSString(string: urlString)
        if let cachedImage = cache.object(forKey: cacheKey) { return cachedImage }
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            
            cache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            return nil
        }
    }
    
    func baseNetworkCall<Result: Codable>(for constructedUrl: String) async throws(NetworkingError) -> Result {
        guard let accessToken: String = try? Configuration.value(for: "API_KEY") else {
            throw .requestFailed(innerError: URLError(.cancelled))
        }
        guard let endPoint = URL(string: constructedUrl) else {
            throw .requestFailed(innerError: URLError(.badURL))
        }
        
        do {
            var networkRequest = URLRequest(url: endPoint)
            networkRequest.httpMethod = "GET"
            networkRequest.timeoutInterval = 10
            networkRequest.allHTTPHeaderFields = [
                "accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            
            let (data, response) = try await URLSession.shared.data(for: networkRequest)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                throw NetworkingError.invalidStatusCode(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            
            let parsedData = try data.decode(to: Result.self)
            return parsedData
        } catch let error as DecodingError {
            throw .decodingFailed(innerError: error)
        } catch let error as EncodingError {
            throw .encodingFailed(innerError: error)
        } catch let error as URLError {
            throw .requestFailed(innerError: error)
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw .otherError(innerError: error)
        }
    }
}

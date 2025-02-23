//
//  MoviesInteractor.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import Foundation

protocol MoviesInteractor: AnyObject {
    var presenter: MoviesPresenter? { get set }
    func getTrendingMovies() async
}

class MoviesInteractorImpl: MoviesInteractor {
    weak var presenter: (any MoviesPresenter)?
    
    func getTrendingMovies() async {
        let constructedUrl = "https://api.themoviedb.org/3/trending/movie/day?language=en-US"
        guard let accessToken: String = try? Configuration.value(for: "API_KEY") else {
            presenter?.didFetchedMovies(result: .failure(.requestFailed(innerError: URLError(.cancelled))))
            return
        }
        guard let endPoint = URL(string: constructedUrl) else {
            presenter?.didFetchedMovies(result: .failure(.requestFailed(innerError: URLError(.badURL))))
            return
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
                presenter?.didFetchedMovies(result: .failure(NetworkingError.invalidStatusCode(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)))
                return
            }
            
            let parsedData = try data.decode(to: Movie.self)
            presenter?.didFetchedMovies(result: .success(parsedData))
        }
        catch let error as DecodingError {
            presenter?.didFetchedMovies(result: .failure(.decodingFailed(innerError: error)))
        } catch let error as EncodingError {
            presenter?.didFetchedMovies(result: .failure(.encodingFailed(innerError: error)))
        } catch let error as URLError {
            presenter?.didFetchedMovies(result: .failure(.requestFailed(innerError: error)))
        } catch let error as NetworkingError {
            presenter?.didFetchedMovies(result: .failure(error))
        } catch {
            presenter?.didFetchedMovies(result: .failure(.otherError(innerError: error)))
        }
    }
}

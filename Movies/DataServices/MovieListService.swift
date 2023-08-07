//
//  MovieListService.swift
//  Movies
//
//  Created by Reeta Dubey on 20/07/23.
//

import Foundation

protocol MovieListService {
    func getMovieListData(_ pageNum: Int, _ completion: @escaping (Result<MovieListDetails, APIError>) -> Void)
}

class DataService: MovieListService {
    
    private struct MovieListServiceConstants {
        static let fileName = "CONTENTLISTINGPAGE-PAGE"
    }
    
    func getMovieListData(_ pageNum: Int, _ completion: @escaping (Result<MovieListDetails, APIError>) -> Void) {
        let string = "\(MovieListServiceConstants.fileName)\(pageNum)"
        guard let path = Bundle.main.path(forResource: string, ofType: "json")
        else {
            return completion(.failure(APIError.invalidURL))
        }
        do {
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)
            let result = try JSONDecoder().decode(MovieListDetails.self, from: data)
            return completion(.success(result))
        } catch {
            print("Unexpected error: \(error).")
            return completion(.failure(APIError.invalidData))
        }
    }
}

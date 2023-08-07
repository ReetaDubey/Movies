//
//  MockMovieListService.swift
//  MoviesTests
//
//  Created by Reeta Dubey on 07/08/23.
//

@testable import Movies

class MockMovieListService: MovieListService {
    var mockResults: Result<MovieListDetails, APIError>?
    func getMovieListData(_ pageNum: Int, _ completion: @escaping (Result<MovieListDetails, APIError>) -> Void) {
        if let result = mockResults {
            completion(result)
        }
        else {
            completion(.failure(APIError.invalidURL))
        }
    }
}

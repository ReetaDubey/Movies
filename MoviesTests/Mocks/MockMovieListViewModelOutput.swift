//
//  MockMovieListViewModelOutput.swift
//  MoviesTests
//
//  Created by Reeta Dubey on 07/08/23.
//

@testable import Movies

class MockMovieListViewModelOutput: MovieListViewModelOutput {
    var title: String?
    var list = [MovieModel]()
    func updateView(with title: String?, list: [MovieModel]) {
        self.title = title
        self.list = list
    }
}
 

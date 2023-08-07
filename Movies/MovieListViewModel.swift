//
//  MovieListViewModel.swift
//  Movies
//
//  Created by Reeta Dubey on 03/08/23.
//

import Foundation

protocol MovieListViewModelOutput: AnyObject {
    func updateView(with title: String?, list: [MovieModel])
}

class MovieListViewModel {
    weak var output: MovieListViewModelOutput?
    private let dataService: MovieListService

    var pageNumber = 0
    var totalPageCount = 1
    var serachResults = [MovieModel]()
    var movieListDetails: MovieListDetails?
    var isSearchActive = false

    init(dataService: MovieListService) {
        self.dataService = dataService
    }
    
    func fetchMovieList() {
        if true == isSearchActive {
            return
        }
        if pageNumber < totalPageCount {
            pageNumber += 1
            dataService.getMovieListData(pageNumber) {
                result in
                switch result {
                case .success(let movieListModel):
                    let totalCount = movieListModel.totalContentItems ?? (movieListModel.contentItems?.count ?? 0)
                    let pageSize = movieListModel.pageSize ?? (movieListModel.contentItems?.count ?? 0)
                    self.totalPageCount = (totalCount != 0 && pageSize != 0) ?
                                            (totalCount/pageSize == 0 ?
                                             totalCount/pageSize : totalCount/pageSize + 1) : 1
                    if nil == self.movieListDetails {
                        self.movieListDetails = movieListModel
                    } else {
                        self.movieListDetails?.updateList(with: movieListModel.contentItems ?? [])
                    }
                case .failure(let error):
                    print("Error fetching movies: \(error)")
                }
                self.output?.updateView(with: self.movieListDetails?.title, list: self.movieListDetails?.contentItems ?? [])
            }
        }
    }
    
    func getSuggestionList(with text: String) -> [MovieModel] {
        isSearchActive = true
        let array = self.movieListDetails?.contentItems?.filter({true == $0.name?.contains(text) })
        return array ?? []
    }
    
    func displayAllMovies() {
        isSearchActive = false
        self.output?.updateView(with: self.movieListDetails?.title, list: self.movieListDetails?.contentItems ?? [])
    }
    
    func displaySearchResults(for text: String) {
        let results = self.movieListDetails?.contentItems?.filter({true == $0.name?.contains(text) }) ?? []
        self.output?.updateView(with: text, list: results)
    }
}


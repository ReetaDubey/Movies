//
//  MovieListViewModelTests.swift
//  MoviesTests
//
//  Created by Reeta Dubey on 06/08/23.
//

import XCTest
@testable import Movies

class MovieListViewModelTests: XCTestCase {
    private var movieService: MockMovieListService!
    private var viewModel: MovieListViewModel!
    private var output: MockMovieListViewModelOutput!
    private var successResult: MovieListDetails!
    
    override func setUpWithError() throws {
        output = MockMovieListViewModelOutput()
        movieService = MockMovieListService()
        viewModel = MovieListViewModel(dataService: movieService)
        viewModel.output = output
        
        let path = Bundle.main.path(forResource: "CONTENTLISTINGPAGE-PAGE1", ofType: "json")
        do {
            let url = URL(fileURLWithPath: path!)
            let data = try Data(contentsOf: url)
            successResult = try JSONDecoder().decode(MovieListDetails.self, from: data)
        } catch {}
        try super.setUpWithError()
    }
    
    func testUpdateView_onSuccess() {
        //given
        movieService.mockResults = .success(successResult)
        
        //when
        viewModel.fetchMovieList()
        
        //then
        XCTAssertEqual(output.title, "Romantic Comedy")
        XCTAssertEqual(output.list.count, 20)
    }
    
    func testUpdateView_onError() {
        movieService.mockResults = .failure(.invalidURL)
        viewModel.fetchMovieList()
        XCTAssertNil(output.title)
        XCTAssertTrue(output.list.isEmpty)
    }
    
    func testViewModelProperties_onSuccess() {
        movieService.mockResults = .success(successResult)
        viewModel.fetchMovieList()
        
        XCTAssertEqual(viewModel.movieListDetails?.title, "Romantic Comedy")
        XCTAssertEqual(viewModel.movieListDetails?.pageNum, 1)
        XCTAssertEqual(viewModel.movieListDetails?.totalContentItems, 54)
        XCTAssertEqual(viewModel.movieListDetails?.pageSize, 20)
        XCTAssertEqual(viewModel.movieListDetails?.contentItems?.count, 20)
        XCTAssertEqual(viewModel.movieListDetails?.contentItems?[0].name, "The Birds")

        XCTAssertEqual(viewModel.pageNumber, 1)
        XCTAssertEqual(viewModel.totalPageCount, 3)
        XCTAssertFalse(viewModel.isSearchActive)
    }
    
    func testViewModelProperties_onFailure() {
        movieService.mockResults = .failure(.invalidURL)
        viewModel.fetchMovieList()
        XCTAssertNil(viewModel.movieListDetails)
        XCTAssertNil(viewModel.movieListDetails?.title)
        XCTAssertNil(viewModel.movieListDetails?.pageNum)
        XCTAssertNil(viewModel.movieListDetails?.totalContentItems)
        XCTAssertNil(viewModel.movieListDetails?.pageSize)
        XCTAssertNil(viewModel.movieListDetails?.contentItems?.count)

        XCTAssertEqual(viewModel.pageNumber, 1)
        XCTAssertEqual(viewModel.totalPageCount, 1)
    }
    
    func testSuggesstionResult_whenMatchExists() {
        movieService.mockResults = .success(successResult)
        viewModel.fetchMovieList()
        let results = viewModel.getSuggestionList(with: "Family Pot")
        
        XCTAssertTrue(viewModel.isSearchActive)
        XCTAssertEqual(results.count, 6)
    }
    
    func testSuggesstionResult_whenMatchDoesntExists() {
        movieService.mockResults = .success(successResult)
        viewModel.fetchMovieList()
        let results = viewModel.getSuggestionList(with: "jdfhsjhdf")
        
        XCTAssertTrue(viewModel.isSearchActive)
        XCTAssertTrue(results.isEmpty)
    }
    
    func testDisplayingAllMovies_whenSearchIsCancelled() {
        movieService.mockResults = .success(successResult)
        viewModel.fetchMovieList()
        
        let _ = viewModel.getSuggestionList(with: "Family Pot")
        XCTAssertTrue(viewModel.isSearchActive)

        let _ = viewModel.displayAllMovies()
        XCTAssertFalse(viewModel.isSearchActive)
        XCTAssertEqual(output.title, "Romantic Comedy")
        XCTAssertEqual(output.list.count, 20)
    }
    
    func testSearchResult_whenMatchExists() {
        movieService.mockResults = .success(successResult)
        viewModel.fetchMovieList()
        let _ = viewModel.displaySearchResults(for: "Family Pot")
        XCTAssertEqual(output.title, "Family Pot")
        XCTAssertEqual(output.list.count, 6)
    }
    
    func testSearchResult_whenMatchDoesntExists() {
        movieService.mockResults = .success(successResult)
        viewModel.fetchMovieList()
        let _ = viewModel.displaySearchResults(for: "jhfsahjfsjbf")
        XCTAssertEqual(output.title, "jhfsahjfsjbf")
        XCTAssertTrue(output.list.isEmpty)
    }

    override func tearDownWithError() throws {
        movieService = nil
        viewModel = nil
        try super.tearDownWithError()
    }
}

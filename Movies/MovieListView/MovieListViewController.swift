//
//  MovieListViewController.swift
//  Movies
//
//  Created by Reeta Dubey on 30/07/23.
//

import UIKit

class MovieListViewController: UIViewController {

    private struct MovieListConstants {
        static let collectionCellPadding: CGFloat = 50.0
        static let collectionCellTextDefaultHeight: CGFloat = 20.0
        static let gradientHeight: CGFloat = 36.0
        static let movieTitleFont = UIFont.init(name: "TitilliumWeb-Light", size: 16) ?? UIFont.systemFont(ofSize: 16)
        static let suggessionCellID = "MovieSuggestionTableViewCellID"
        static let MovieListCellID = "MovieListCellID"
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var customView: CustomNavigationView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gradientViewTopSpaceConstraint: NSLayoutConstraint!
    
    var viewModel = MovieListViewModel(dataService: DataService())
    var movieList = [MovieModel]()
    var suggestionList = [MovieModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        reloadCollectionView()
    }
    
    func setupView() {
        addGradient()
        viewModel.output = self
        viewModel.fetchMovieList()
        if let layout = collectionView?.collectionViewLayout as? MovieListLayout {
          layout.delegate = self
        }
        customView.delegate = self
    }

    func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.gradientView.bounds
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        self.gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async {
            if let layout = self.collectionView.collectionViewLayout as? MovieListLayout {
                layout.reloadData()
            }
            self.collectionView.reloadData()
        }
    }
    
    func displayGenreSpecificMovies() {
        DispatchQueue.main.async {
            self.tableView.isHidden = true
        }
        self.viewModel.displayAllMovies()
    }
    
    func displaySearchSpecificResults(for text: String) {
        DispatchQueue.main.async {
            self.tableView.isHidden = true
            self.customView.exitFromSearch()
            self.viewModel.displaySearchResults(for: text)
        }
    }
}

//MARK: - MovieListViewModelOutput
extension MovieListViewController: MovieListViewModelOutput {
    func updateView(with title: String?, list: [MovieModel]) {
        self.movieList = list
        reloadCollectionView()
        self.customView.updateBackButtonTitle(title ?? "")
    }
}

//MARK: - UICollectionViewDataSource
extension MovieListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListConstants.MovieListCellID, for: indexPath as IndexPath) as! MovieListCell
        cell.movie = movieList[indexPath.item]
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension MovieListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.movieList.count - 1 {
            viewModel.fetchMovieList()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= MovieListConstants.gradientHeight && scrollView.contentOffset.y >= 0 {
            self.gradientViewTopSpaceConstraint.constant = scrollView.contentOffset.y - MovieListConstants.gradientHeight
        }
    }
}

//MARK: - MovieListLayoutDelegate
extension MovieListViewController: MovieListLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForTextAtIndexPath indexPath:IndexPath, width: CGFloat) -> CGFloat {
        let height = movieList[indexPath.row].name?.height(withConstrainedWidth: width, font: MovieListConstants.movieTitleFont)
        return (height ?? MovieListConstants.collectionCellTextDefaultHeight) + MovieListConstants.collectionCellPadding
  }
}

//MARK: - NavigationProtocol
extension MovieListViewController: NavigationProtocol {
    func didSelectBackButton() {
        self.displayGenreSpecificMovies()
    }
    
    func searchTextChanged(with string: String) {
        self.suggestionList = viewModel.getSuggestionList(with: string)
        DispatchQueue.main.async {
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    func searchCancelButtonClicked() {
        self.displayGenreSpecificMovies()
    }
    
    func searchButtonClicked(with text: String) {
        displaySearchSpecificResults(for: text)
    }
}

//MARK: - UITableViewDataSource
extension MovieListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.suggestionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieListConstants.suggessionCellID, for: indexPath) as? MovieSuggestionTableViewCell
        cell?.textLabel?.text = self.suggestionList[indexPath.row].name
        return cell ?? UITableViewCell()
    }
}

//MARK: - UITableViewDelegate
extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = self.suggestionList[indexPath.row].name ?? ""
        displaySearchSpecificResults(for: text)
    }
}

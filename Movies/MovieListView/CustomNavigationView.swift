//
//  CustomNavigationView.swift
//  Movies
//
//  Created by Reeta Dubey on 30/07/23.
//

import Foundation
import UIKit

protocol NavigationProtocol: AnyObject {
    func didSelectBackButton()
    func searchTextChanged(with string: String)
    func searchCancelButtonClicked()
    func searchButtonClicked(with text: String)
}

class CustomNavigationView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backTitleButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarLeadingConstraint: NSLayoutConstraint!
    weak var delegate: NavigationProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomNavigationView", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
        self.setupView()
    }
    
    @IBAction func didSelectBackButton(_ button: UIButton) {
        searchBar.resignFirstResponder()
        searchBarLeadingConstraint.constant = 0
        self.delegate?.didSelectBackButton()
    }
    
    @IBAction func didSelectSearchButton(_ button: UIButton) {
        searchBarLeadingConstraint.constant = -self.bounds.width
    }
    
    func setupView() {
        searchBar.showsCancelButton = true
    }
    
    func updateBackButtonTitle(_ title: String) {
        self.backTitleButton.setTitle(title, for: .normal)
        self.backTitleButton.setTitle(title, for: .selected)
    }
    
    func exitFromSearch() {
        searchBar.text = nil
        searchBar.endEditing(true)
        searchBarLeadingConstraint.constant = 0
    }
}

extension CustomNavigationView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchTextChanged(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.exitFromSearch()
        delegate?.searchButtonClicked(with: searchBar.text ?? "")
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.exitFromSearch()
        delegate?.searchCancelButtonClicked()
    }
}

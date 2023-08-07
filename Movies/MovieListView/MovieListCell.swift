//
//  MovieListCell.swift
//  Movies
//
//  Created by Reeta Dubey on 03/08/23.
//

import UIKit
class MovieListCell: UICollectionViewCell {
    struct MovieListCellConstants {
        static let imagePlaceHolder = "placeholder_for_missing_posters"
    }
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true
    }
    
    var movie: MovieModel? {
        didSet {
            if let movie = movie {
                imageView.image = UIImage(named: movie.posterImage) ?? UIImage(named: MovieListCellConstants.imagePlaceHolder)
                titleLabel.text = movie.name
            }
        }
    }
}

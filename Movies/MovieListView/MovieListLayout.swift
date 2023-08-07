//
//  MovieListLayout.swift
//  Movies
//
//  Created by Reeta Dubey on 04/08/23.
//

import UIKit
protocol MovieListLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForTextAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat
}

class MovieListLayout: UICollectionViewLayout {
    weak var delegate: MovieListLayoutDelegate?
    
    private var numberOfColumns = 3
    private let cellPadding: CGFloat = 6
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {

        //calculate the layout attributes only if cache is empty and the collection view exists
        guard
            cache.isEmpty == true,
            let collectionView = collectionView
        else {
            return
        }
        
        //xOffset tracks x-coordinate for every column depending on orientation and number of columns
        let orientation = UIDevice.current.orientation
        numberOfColumns = orientation.isLandscape ? 5 : 3
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        
        //yOffset array tracks the y-position for every column.
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            //Calculating height of the each item considering text height.
            let imageHeight = columnWidth * 1.4
            let labelHeight = delegate?.collectionView(
                collectionView,
                heightForTextAtIndexPath: indexPath, width: columnWidth) ?? 180
            let height = cellPadding * 2 + imageHeight + labelHeight
            let frame = CGRect(x: xOffset[column],
                               y: yOffset[column],
                               width: columnWidth,
                               height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            //contentHeight should account for the frame of the newly calculated item
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    func reloadData() {
        self.cache = [UICollectionViewLayoutAttributes]()
    }
}

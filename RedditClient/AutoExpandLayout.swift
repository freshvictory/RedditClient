//
//  AutoExpandLayout.swift
//  RedditClient
//
//  Created by Justin Renjilian on 4/30/16.
//  Copyright © 2016 Justin Renjilian. All rights reserved.
//

import UIKit

class AutoExpandLayout: UICollectionViewLayout {
    
    // how much does the user need to scroll before the next item expands
    var scrollAmount: CGFloat = 200
    
    var cache = [UICollectionViewLayoutAttributes]()
    
    var currentItemIndex: Int {
        get {
            return max(0, Int(collectionView!.contentOffset.y / scrollAmount))
        }
    }
    
    var howCloseIsNextItem: CGFloat {
        return (collectionView!.contentOffset.y / scrollAmount) - CGFloat(currentItemIndex)
    }
    
    var collectionViewWidth: CGFloat {
        get {
            return CGRectGetWidth(collectionView!.bounds)
        }
    }
    
    var collectionViewHeight: CGFloat {
        get {
            return CGRectGetHeight(collectionView!.bounds)
        }
    }
    
    var numPosts: Int {
        return collectionView!.numberOfItemsInSection(0)
    }
    
    override func collectionViewContentSize() -> CGSize {
        let contentWidth = (CGFloat(numPosts) * scrollAmount) + (collectionViewHeight - scrollAmount)
        return CGSize(width: contentWidth, height: collectionViewHeight)
    }
    
    override func prepareLayout() {
        let regularWidth: CGFloat = 200;
        let selectedWidth: CGFloat = 400;
        
        var frame = CGRectZero
        var x: CGFloat = 0
        
        for i in 0..<numPosts {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            let currentAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            
            currentAttributes.zIndex = i
            var width = regularWidth
            
            if indexPath.item == currentItemIndex {
                let offset = regularWidth * howCloseIsNextItem
                x = collectionView!.contentOffset.x - offset;
                width = selectedWidth;
            } else if indexPath.item == (currentItemIndex + 1) && indexPath.item != numPosts {
                // 5
                let maxX = x + regularWidth
                width = regularWidth + max((selectedWidth - regularWidth) * howCloseIsNextItem, 0)
                x = maxX - collectionViewWidth
            }
            
            frame = CGRect(x: x, y: 0, width: width, height: collectionViewHeight)
            currentAttributes.frame = frame
            cache.append(currentAttributes)
            x = CGRectGetMaxY(frame)
        }
    }
    
    /* Return all attributes in the cache whose frame intersects with the rect passed to the method */
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    /* Return true so that the layout is continuously invalidated as the user scrolls */
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
}

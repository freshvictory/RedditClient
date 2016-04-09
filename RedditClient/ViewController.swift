//
//  ViewController.swift
//  RedditClientUI
//
//  Created by Justin Renjilian on 4/5/16.
//  Copyright © 2016 Justin Renjilian. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource {
    
    // The text field for entering a specific subreddit
    @IBOutlet weak var subredditTextField: UITextField!
    
    @IBOutlet weak var postCollectionView: UICollectionView!

    // MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        postCollectionView.reloadData()
        Reddit.refreshReddit()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Search Field
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let subreddit = textField.text {
            Reddit.refreshReddit(Reddit.subredditURL(subreddit))
        }
        textField.resignFirstResponder()
        
        // Scroll back to beginning
//        postCollectionView.performBatchUpdates({
            self.postCollectionView.reloadData()
//            return
//        }){
//            completed in
//            //4
//            if self.chosenPost != nil {
//                self.postCollectionView.scrollToItemAtIndexPath(
//                    ,
//                    atScrollPosition: .CenteredVertically,
//                    animated: true)
//            }
//        }
        
        return true
    }

    // MARK: Collection View
    
    let articleReuseIdentifier = "articleCard"
    let imageReuseIdentifier = "imageCard"
    let textReuseIdentifier = "textCard"
    let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var defaultHeight: CGFloat = 300 {
        didSet {
            if defaultHeight != oldValue {
                postCollectionView.collectionViewLayout.invalidateLayout()
                postCollectionView.collectionViewLayout.prepareLayout()
            }
        }
    }
    let defaultWidth: CGFloat = 200
    
    var chosenPost: NSIndexPath? {
        didSet {
            var indexPaths = [NSIndexPath]()
            if chosenPost != nil {
                indexPaths.append(chosenPost!)
            }
            if oldValue != nil {
                indexPaths.append(oldValue!)
            }
            
            postCollectionView.performBatchUpdates({
                self.postCollectionView.reloadItemsAtIndexPaths(indexPaths)
                return
            }){
                completed in
                //4
                if self.chosenPost != nil {
                    self.postCollectionView.scrollToItemAtIndexPath(
                        self.chosenPost!,
                        atScrollPosition: .CenteredVertically,
                        animated: true)
                }
            }
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Reddit.posts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let post = postAtIndexPath(indexPath)
        
        // Self Post
        if post.isSelf {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(textReuseIdentifier, forIndexPath: indexPath) as? TextCardCollectionViewCell
            buildCell(cell!, post: post)
            return cell!
        } // Image Post
        else if post.image != nil {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(imageReuseIdentifier, forIndexPath: indexPath) as? ImageCardCollectionViewCell
            buildCell(cell!, post: post)
            return cell!
        } // Article Post
        else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(articleReuseIdentifier, forIndexPath: indexPath) as? ArticleCardCollectionViewCell
            buildCell(cell!, post: post)
            return cell!
        }
    }
    
    // Build a TextCard using the given post
    func buildCell(cell: TextCardCollectionViewCell, post: Post) {
        cell.titleLabel.text = post.title
        cell.bodyLabel.text = post.selftext
    }
    
    // Build an ImageCard using the given post
    func buildCell(cell: ImageCardCollectionViewCell, post: Post) {
        cell.titleLabel.text = post.title
        cell.imageView.image = post.image
        
        // Text Shadow
//        cell.textShadowView.bounds = cell.titleLabel.frame
//        let gradient: CAGradientLayer = CAGradientLayer()
//        gradient.frame = cell.textShadowView.bounds
//        gradient.colors = [UIColor.blackColor().CGColor, UIColor.clearColor().CGColor]
////        gradient.opacity = 0.2
//        cell.textShadowView.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    func buildCell(cell: ArticleCardCollectionViewCell, post: Post) {
        cell.titleLabel.text = post.title
//        if post.mediaEmbed != nil {
//            cell.webView.allowsInlineMediaPlayback = true
//            cell.webView.loadHTMLString(post.mediaEmbed!, baseURL: NSBundle.mainBundle().bundleURL)
//        } else {
            cell.webView.loadRequest(NSURLRequest(URL: post.url))
//        }
    }
    
    func shapeCell(cell: UICollectionViewCell) {
        cell.contentView.layer.cornerRadius = 2.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clearColor().CGColor
        cell.contentView.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.blackColor().CGColor
        //        cell!.layer.backgroundColor = UIColor.clearColor().CGColor
        cell.layer.shadowOffset = CGSizeMake(0, 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        //        cell!.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).CGPath
    }
    
    override func viewDidLayoutSubviews() {
        defaultHeight = postCollectionView.bounds.size.height
    }
    
    func postAtIndexPath(indexPath: NSIndexPath) -> Post {
        return Reddit.posts[indexPath.row]
    }

}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        
        
//        if indexPath == chosenPost {
//            var size = view.bounds.size
//            size.height -= topLayoutGuide.length
//            size.height -= (sectionInsets.top + sectionInsets.right)
//            size.width -= (sectionInsets.left + sectionInsets.right)
//            return flickrPhoto.sizeToFillWidthOfSize(size)
//        }
        postCollectionView.collectionViewLayout.invalidateLayout()
        return CGSize(width: defaultWidth, height: defaultHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView,
                                 shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if chosenPost == indexPath {
            chosenPost = nil
        }
        else {
            chosenPost = indexPath
        }
        return false
    }
}


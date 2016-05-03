//
//  FullscreenPageViewController.swift
//  RedditClient
//
//  Created by Justin Renjilian on 4/30/16.
//  Copyright © 2016 Justin Renjilian. All rights reserved.
//

import UIKit

class FullscreenPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var postCollectionView: UICollectionView?
    
    var fullscreenPostViewControllers: [UIViewController] = [UIViewController]()
    
    let upvoteColor = UIColor(red: CGFloat(0xFF)/CGFloat(255), green: CGFloat(0x8B)/CGFloat(255), blue: CGFloat(0x60)/CGFloat(255), alpha: 1)
    let downvoteColor = UIColor(red: CGFloat(0x94)/CGFloat(255), green: CGFloat(0x94)/CGFloat(255), blue: CGFloat(0xFF)/CGFloat(255), alpha: 1)
    
    @IBAction func doneButton(sender: UIBarButtonItem) {
        postCollectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0), atScrollPosition: .Left, animated: false)
        dismissViewControllerAnimated(true, completion: nil)
    }
    var currentIndex = 0

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBAction func savePost(sender: UIBarButtonItem) {
        Reddit.toggleSave(Reddit.posts[currentIndex])
        setupButtons()
    }
    
    @IBOutlet weak var downvoteButton: UIBarButtonItem!
    @IBAction func downvotePost(sender: UIBarButtonItem) {
        Reddit.downvote(Reddit.posts[currentIndex])
        setupButtons()
    }
    
    @IBOutlet weak var upvoteButton: UIBarButtonItem!
    @IBAction func upvotePost(sender: UIBarButtonItem) {
        Reddit.upvote(Reddit.posts[currentIndex])
        setupButtons()
    }
    
    @IBOutlet weak var previousButton: UIBarButtonItem!
    @IBAction func previousPost(sender: UIBarButtonItem) {
        if currentIndex != 0 {
            currentIndex -= 1
            navigationItem.title = Reddit.posts[currentIndex].title
            setViewControllers([fullscreenPostViewControllers[currentIndex]], direction: .Reverse, animated: true, completion: nil)
            previousButton.enabled = currentIndex != 0
            nextButton.enabled = currentIndex != Reddit.posts.count - 1
            setupButtons()
        }
    }
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBAction func nextPost(sender: UIBarButtonItem) {
        if currentIndex != Reddit.posts.count - 1 {
            currentIndex += 1
            navigationItem.title = Reddit.posts[currentIndex].title
            setViewControllers([fullscreenPostViewControllers[currentIndex]], direction: .Forward, animated: true, completion: nil)
            nextButton.enabled = currentIndex != Reddit.posts.count - 1
            previousButton.enabled = currentIndex != 0
            setupButtons()
        }
    }
    
    func setupButtons(){
        if Reddit.userMode {
            upvoteButton.enabled = true
            downvoteButton.enabled = true
            saveButton.enabled = true
            let post = Reddit.posts[currentIndex]
            if(post.userVote == 1){
                upvoteButton.tintColor = upvoteColor
                downvoteButton.tintColor = nil
            } else if(post.userVote == -1){
                downvoteButton.tintColor = downvoteColor
                upvoteButton.tintColor = nil
            } else {
                upvoteButton.tintColor = nil
                downvoteButton.tintColor = nil
            }
            if post.saved! {
                saveButton.title = "unsave"
            } else {
                saveButton.title = "save"
            }
        } else {
            upvoteButton.tintColor = nil
            downvoteButton.tintColor = nil
            saveButton.title = "save"
            upvoteButton.enabled = false
            downvoteButton.enabled = false
            saveButton.enabled = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.toolbarHidden = false
        
        setupButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAllViewControllers()
        
        dataSource = self
        previousButton.enabled = currentIndex != 0
        let firstViewController = fullscreenPostViewControllers[currentIndex]
        navigationItem.title = Reddit.posts[currentIndex].title
        setViewControllers([firstViewController],
                           direction: .Forward,
                           animated: true,
                           completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        print("attempting to scroll left")
        guard let viewControllerIndex = fullscreenPostViewControllers.indexOf(viewController) else {
            return nil
        }
        currentIndex = viewControllerIndex
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard fullscreenPostViewControllers.count > previousIndex else {
            return nil
        }
        
        previousButton.enabled = currentIndex != 0
        nextButton.enabled = currentIndex != Reddit.posts.count - 1
        navigationItem.title = Reddit.posts[currentIndex].title
        setupButtons()
        return fullscreenPostViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        print("attempting to scroll right")
        guard let viewControllerIndex = fullscreenPostViewControllers.indexOf(viewController) else {
            return nil
        }
        
        currentIndex = viewControllerIndex
        
        let nextIndex = viewControllerIndex + 1
        let count = fullscreenPostViewControllers.count
        
        guard count != nextIndex else {
            return nil
        }
        
        guard count > nextIndex else {
            return nil
        }
        nextButton.enabled = nextIndex != Reddit.posts.count - 1
        previousButton.enabled = currentIndex != 0
        navigationItem.title = Reddit.posts[currentIndex].title
        setupButtons()
        return fullscreenPostViewControllers[nextIndex]
    }
    
    func createFullscreenPostViewController() -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("fullscreenPost")
    }
    
    func createAllViewControllers() {
        for post in Reddit.posts {
            let view = createFullscreenPostViewController() as? FullscreenPost
            view?.url = post.url
            fullscreenPostViewControllers.append(view!)
        }
    }
}

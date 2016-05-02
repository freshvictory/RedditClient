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
    
    @IBAction func doneButton(sender: UIBarButtonItem) {
        postCollectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0), atScrollPosition: .Left, animated: false)
        dismissViewControllerAnimated(true, completion: nil)
    }
    var currentIndex = 0

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBAction func savePost(sender: UIBarButtonItem) {
        
    }
    
    @IBOutlet weak var downvoteButton: UIBarButtonItem!
    @IBAction func downvotePost(sender: UIBarButtonItem) {
        
    }
    
    @IBOutlet weak var upvoteButton: UIBarButtonItem!
    @IBAction func upvotePost(sender: UIBarButtonItem) {
        
    }
    
    @IBOutlet weak var previousButton: UIBarButtonItem!
    @IBAction func previousPost(sender: UIBarButtonItem) {
        if currentIndex != 0 {
            currentIndex--
            navigationItem.title = Reddit.posts[currentIndex].title
            setViewControllers([fullscreenPostViewControllers[currentIndex]], direction: .Reverse, animated: true, completion: nil)
            previousButton.enabled = currentIndex != 0
            nextButton.enabled = currentIndex != Reddit.posts.count - 1
        }
    }
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBAction func nextPost(sender: UIBarButtonItem) {
        if currentIndex != Reddit.posts.count - 1 {
            currentIndex++
            navigationItem.title = Reddit.posts[currentIndex].title
            setViewControllers([fullscreenPostViewControllers[currentIndex]], direction: .Forward, animated: true, completion: nil)
            nextButton.enabled = currentIndex != Reddit.posts.count - 1
            previousButton.enabled = currentIndex != 0
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.toolbarHidden = false
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

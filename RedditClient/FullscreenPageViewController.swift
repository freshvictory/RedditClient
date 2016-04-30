//
//  FullscreenPageViewController.swift
//  RedditClient
//
//  Created by Justin Renjilian on 4/30/16.
//  Copyright © 2016 Justin Renjilian. All rights reserved.
//

import UIKit

class FullscreenPageViewController: UIPageViewController {
    
    var fullscreenPostViewControllers: [UIViewController] = [UIViewController]()
    
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAllViewControllers()
        print("Received index: \(currentIndex)")
        
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
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard fullscreenPostViewControllers.count > previousIndex else {
            return nil
        }
        navigationItem.title = Reddit.posts[previousIndex].title
        return fullscreenPostViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        print("attempting to scroll right")
        guard let viewControllerIndex = fullscreenPostViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let count = fullscreenPostViewControllers.count
        
        guard count != nextIndex else {
            return nil
        }
        
        guard count > nextIndex else {
            return nil
        }
        navigationItem.title = Reddit.posts[nextIndex].title
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
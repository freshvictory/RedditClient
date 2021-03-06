//
//  Post.swift
//  Test
//
//  Created by Justin Renjilian on 2/2/16.
//  Copyright © 2016 Justin Renjilian. All rights reserved.
//

import Foundation
import UIKit

class Post {
    var title: String
    var op: String
    var subreddit: String
    var url: NSURL
    var votes: Int
    var comments: Int
    var domain: String
    var image: UIImage?
    var isSelf: Bool
    var selftext: String?
    var mediaEmbed: String?
    var previewURL: NSURL?
    var name: String?
    var userVote: Int?
    var saved: Bool?
    //var commentLink: NSURL

    init(name: String, title: String, op: String, subreddit: String, url: NSURL, votes: Int, comments: Int, domain: String, isSelf: Bool, selftext: String, previewURL: NSURL, userVote: Int, saved: Bool /*, commentLink: NSURL*/) {
        self.name = name
        self.title = title
        self.op = op
        self.subreddit = subreddit
        self.url = url
        self.votes = votes
        self.comments = comments
        self.domain = domain
        self.isSelf = isSelf
        self.selftext = selftext
        self.previewURL = previewURL
        self.userVote = userVote
        self.saved = saved
        loadImage { (post, error) in
            //add something later
        }
        //self.commentLink = commentLink
    }
    
    func loadImage(completion: (post: Post, error: NSError?) -> Void) {
        if previewURL != nil && previewURL != NSURL() {
            let loadRequest = NSURLRequest(URL: previewURL!)
            NSURLConnection.sendAsynchronousRequest(loadRequest, queue: NSOperationQueue.mainQueue()) {
                resoponse, data, error in
                self.image = nil
                if error != nil {
                    completion(post: self, error: error)
                    return
                }
                
                if data != nil {
                    let returnedImage = UIImage(data: data!)
                    self.image = returnedImage
                    completion(post: self, error: nil)
                    return
                }
                
                completion(post: self, error: nil)
            }
        }
    }
}
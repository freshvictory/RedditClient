//
//  FrontPage.swift
//  Test
//
//  Created by Justin Renjilian on 2/2/16.
//  Copyright © 2016 Justin Renjilian. All rights reserved.
//

import Foundation
import UIKit

typealias Payload = [String: AnyObject]

class Reddit {
  
    static var posts: [Post] = []
    
    static var token: String?

    static func refreshReddit(reddit: String = "https://www.reddit.com/") -> Void {
        posts = []
        let url = NSURL(string: reddit + ".json")
        let request = NSURLRequest(URL: url!)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        do {
          let data: NSData = try NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
          var json: Payload! = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Payload
          
          guard let all = json["data"] as? Payload, let children = all["children"] as? [Payload]
            else {
              return
          }
          
          for post in children {
            guard let postdata = post["data"] as? Payload
              else {
                continue
            }
            if let nextPost = createPost(postdata) {
              posts.append(nextPost)
            }
          }
          
        } catch {
          print(error)
        }
    }

    static func subredditURL(subreddit: String) -> String {
        return "https://www.reddit.com/r/\(subreddit)"
    }

    static func createPost(postdata: Payload) -> Post? {

        guard let title = postdata["title"] as? String, let op = postdata["author"] as? String, let votes = postdata["score"] as? Int, let comments = postdata["num_comments"] as? Int, var url = NSURL(string: (postdata["url"] as? String)!), let subreddit = postdata["subreddit"] as? String, let domain = postdata["domain"] as? String, let isSelf = postdata["is_self"] as? Bool, let selfText = postdata["selftext"] as? String
          else {
            return nil
        }
        
        // Let's see if there's an image for this
        if let imagePreview = postdata["preview"] as? Payload {
            if let images = imagePreview["images"] as? [Payload] {
                if let source = images.first!["source"] {
                    if let imageURL = NSURL(string: (source["url"] as? String)!) {
                        print(imageURL.absoluteString)
                        url = imageURL
                    }
                }
            }
        }
        
        let post = Post(title: title, op: op, subreddit: subreddit, url: url, votes: votes, comments: comments, domain: domain, isSelf: isSelf, selftext: selfText)
        
        // Let's see if there's embeddable media
        if let embed = postdata["media_embed"] as? Payload {
            if let content = embed["content"] as? String {
                post.mediaEmbed = content
            }
        }

        return post
    }
    
    static func sendAuthRequest(){
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.reddit.com/api/v1/authorize?client_id=OI7wplUN-g7pGA&response_type=token&state=RANDOM_STRING&redirect_uri=readitClient://oauth&scope=identity,flair,history,mysubreddits,read,report,save,subscribe,vote")!)
    }
}
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
    
    static var userMode: Bool = false
    static var loggedIn: Bool = false
    
    static var lastSubreddit: String?
    
    static var curUser: User?
    
    //Use this to load a new subreddit starting from the first page
    static func loadNewSubreddit(redditName: String?) {
        if(!loggedIn){
            logInNonUser()
        }
        lastSubreddit = redditName
        
        posts = []
        var urlString = "https://oauth.reddit.com/"
        if(redditName != nil && redditName != ""){
            urlString = urlString + "r/\(redditName!)/"
        }
        
        print("loading reddit: \(redditName) from \(urlString)")
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        request.addValue("bearer \(token!)", forHTTPHeaderField: "Authorization")
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
    
    static func reloadCurrentSubreddit(){
        loadNewSubreddit(lastSubreddit)
    }

    static func createPost(postdata: Payload) -> Post? {
        
        print("\n\n****POST****\n\n\(postdata)")

        guard let title = postdata["title"] as? String, let op = postdata["author"] as? String, let votes = postdata["score"] as? Int, let comments = postdata["num_comments"] as? Int, let url = NSURL(string: (postdata["url"] as? String)!), let subreddit = postdata["subreddit"] as? String, let domain = postdata["domain"] as? String, let isSelf = postdata["is_self"] as? Bool, let selfText = postdata["selftext"] as? String, let name = postdata["name"] as? String, let saved = postdata["saved"] as? Int
          else {
            return nil
        }
        
        let likes = postdata["likes"] as? Int
        var vote: Int
        if likes == nil {
            vote = 0
        } else if likes == 1 {
            vote = 1
        } else if likes == 0 {
            vote = -1
        } else {
            vote = 0
            print("error reading likes field: \(likes)")
        }
        
        print("likes \(likes) -> vote \(vote)")
        var previewURL: NSURL = NSURL()
        // Let's see if there's an image for this
        if let imagePreview = postdata["preview"] as? Payload {
            if let images = imagePreview["images"] as? [Payload] {
                if let source = images.first!["source"] {
                    if let imageURL = NSURL(string: (source["url"] as? String)!) {
                        previewURL = imageURL
                    }
                }
            }
        }
        
        let post = Post(name: name, title: title, op: op, subreddit: subreddit, url: url, votes: votes, comments: comments, domain: domain, isSelf: isSelf, selftext: selfText, previewURL: previewURL, userVote: vote, saved: saved != 0)
        
        // Let's see if there's embeddable media
        if let embed = postdata["media_embed"] as? Payload {
            if let content = embed["content"] as? String {
                post.mediaEmbed = content
            }
        }

        return post
    }
    
    static func getLoginURL() -> NSURL {
        return NSURL(string: "https://www.reddit.com/api/v1/authorize?client_id=OI7wplUN-g7pGA&response_type=token&state=RANDOM_STRING&redirect_uri=readitClient://oauth&scope=identity,mysubreddits,read,save,vote")!
    }
    
    static func logInNonUser(){
        print("logging in without a user")
        // set up the base64-encoded credentials
        let username = "OI7wplUN-g7pGA"
        let password = ""
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.init(rawValue: 0))
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.reddit.com/api/v1/access_token")!)
        request.HTTPMethod = "POST"
        let bodyData = "grant_type=https://oauth.reddit.com/grants/installed_client&device_id=\(NSUUID().UUIDString)"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        do {
            let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            let data: NSData = try NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
            var json: Payload! = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Payload
            
            setNonUserToken(json["access_token"] as! String)
        } catch {
            print(error)
        }
        
    }
    
    static func setUserToken(newToken: String){
        loggedIn = true
        userMode = true
        token = newToken
        loadUserData()
    }
    
    static func loadUserData(){
        if !userMode {
            return
        }
        print("loading user data")
        let url = NSURL(string: "https://oauth.reddit.com/api/v1/me")
        let request = NSMutableURLRequest(URL: url!)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        request.addValue("bearer \(token!)", forHTTPHeaderField: "Authorization")
        do {
            let data: NSData = try NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
            let json: Payload! = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Payload
            curUser = User(username: json["name"] as! String, linkKarma: json["link_karma"] as! Int, commentKarma: json["comment_karma"] as! Int)
        } catch {
            print(error)
        }
    }
    
    static func setNonUserToken(newToken: String){
        loggedIn = true
        userMode = false
        token = newToken
        curUser = nil
    }
    
    static func voteOnPost(post: Post, direction: Int){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://oauth.reddit.com/api/vote?dir=\(direction)&id=\(post.name!)")!)
        request.HTTPMethod = "POST"
        request.addValue("bearer \(token!)", forHTTPHeaderField: "Authorization")
        do {
            let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            let data: NSData = try NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
            let json: Payload! = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Payload
            post.userVote = direction
            print(json)
        } catch {
            print(error)
        }
    }
    
    static func upvote(post: Post){
        if post.userVote == 1 {
            voteOnPost(post, direction: 0)
        } else {
            voteOnPost(post, direction: 1)
        }
    }
    
    static func downvote(post: Post){
        if(post.userVote == -1){
            voteOnPost(post, direction: 0)
        } else {
            voteOnPost(post, direction: -1)
        }
    }
    
    static func toggleSave(post: Post){
        if post.saved! {
            unsavePost(post)
        } else {
            savePost(post)
        }
    }
    
    static func savePost(post: Post){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://oauth.reddit.com/api/save?id=\(post.name!)")!)
        request.HTTPMethod = "POST"
        request.addValue("bearer \(token!)", forHTTPHeaderField: "Authorization")
        do {
            let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            let data: NSData = try NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
            let json: Payload! = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Payload
            print(json)
            post.saved = true
        } catch {
            print(error)
        }
    }
    
    static func unsavePost(post: Post){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://oauth.reddit.com/api/unsave?id=\(post.name!)")!)
        request.HTTPMethod = "POST"
        request.addValue("bearer \(token!)", forHTTPHeaderField: "Authorization")
        do {
            let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            let data: NSData = try NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
            let json: Payload! = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? Payload
            print(json)
            post.saved = false
        } catch {
            print(error)
        }
    }
}

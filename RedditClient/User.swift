//
//  User.swift
//  RedditClient
//
//  Created by Steven Miller on 5/2/16.
//  Copyright © 2016 Justin Renjilian. All rights reserved.
//

import Foundation
class User {
    var username: String
    var linkKarma: Int
    var commentKarma: Int
    
    init(username: String, linkKarma: Int, commentKarma: Int){
        self.username = username
        self.linkKarma = linkKarma
        self.commentKarma = commentKarma
    }
}
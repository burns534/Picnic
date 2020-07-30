//
//  User.swift
//  Picnic
//
//  Created by Kyle Burns on 7/30/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import Foundation

struct User: Codable, Hashable {
    var uid: String
    var posts: [String]
    var ratedPosts: [String]
    var wouldVisit: [String]
    var haveVisited: [String]
    
    init() {
        uid = ""
        posts = []
        ratedPosts = []
        wouldVisit = []
        haveVisited = []
    }
    
    init(uid: String, posts: [String], ratedPosts: [String], wouldVisit: [String], haveVisited: [String]) {
        self.uid = uid
        self.posts = posts
        self.ratedPosts = ratedPosts
        self.wouldVisit = wouldVisit
        self.haveVisited = haveVisited
    }
}

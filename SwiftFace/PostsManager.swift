//
//  PostsManager.swift
//  SwiftFace
//
//  Created by Dmitry Goncharenko on 8/28/14.
//  Copyright (c) 2014 Dmitry Goncharenko. All rights reserved.
//

import Foundation

class PostsManager {
    class func loadPosts(completionBlock: () -> ()) {
        SharingManager.sharedInstance.facebookFeed { (responseData, urlResponse, requestError) -> () in
            if requestError != nil {
                println("\(requestError.description)")
            } else if urlResponse.statusCode == 200 {
                var jsonParseError : NSError?
                let feedResponseDictionary = NSJSONSerialization.JSONObjectWithData(responseData, options:.AllowFragments, error: &jsonParseError) as NSDictionary
                if jsonParseError != nil {
                    println("\(jsonParseError!.description)")
                }
                let mapper : JSONMapper = JSONMapper(jsonDictionary: feedResponseDictionary)
                mapper.parseJSON(completionBlock)
            }
        }
    }
    
    class func likeMessage(isLike: Bool, likeURL: NSURL!, complectionBlock: () -> Void) {
        SharingManager.sharedInstance.likeAction(isLike, likeURL: likeURL) { (responseData, urlResponse, requestError) -> Void in
            println("\(urlResponse.description)")
            if urlResponse.statusCode == 200 {
                complectionBlock()
            }
        }
    }
}
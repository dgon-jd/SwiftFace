//
//  Mapper.swift
//  SwiftFace
//
//  Created by Dmitry Goncharenko on 8/21/14.
//  Copyright (c) 2014 Dmitry Goncharenko. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class JSONMapper {
    var json: NSDictionary
    private let dateFormatter : NSDateFormatter = {
        let theFormatter = NSDateFormatter()
        theFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        return theFormatter
        }()
    
    init(jsonDictionary: NSDictionary) {
        self.json = jsonDictionary
    }
    
    func parseJSON (completionBlock: () -> Void) {
        if let theContext = CoreDataManager.sharedInstance.backgroundContext {
            theContext.performBlockAndWait({
                var i = 0
                var postsArray : [NSDictionary] = self.json["data"] as [NSDictionary]
                
                for postDic in postsArray {
                    
                    println("\(postDic)")
                    
                    let thePost : FacebookPost = FacebookPost.createFacebookPost(postDic["id"] as NSString, context: theContext)
                    let theUser : FacebookUser = FacebookUser.createUser(postDic.valueForKeyPath("from.id") as NSString, context: theContext)
                    theUser.userName = postDic.valueForKeyPath("from.name") as? NSString
                    thePost.facebookPostID = postDic["id"] as NSString
                    thePost.author = theUser
                    thePost.fbMessage = postDic["message"] as? NSString
                    thePost.created_at = self.dateFormatter.dateFromString(postDic["created_time"] as NSString)
                    thePost.isLiked = NSNumber.numberWithBool(false)
                    // Actions
                    var actionsArray = postDic["actions"] as? [NSDictionary]
                    
                    if let theActionArray = actionsArray {
                        for theAction in theActionArray {
                            switch theAction["name"] as String {
                            case "Like": thePost.likeURL = theAction["link"] as? NSString
                            default: continue
                            }
                        }
                    }
                    
                    // Application
                    if let appDic = postDic["application"] as? NSDictionary {
                        let theApp = FacebookApp.createFacebookApp(appDic["id"] as String, context: theContext)
                        theApp.appName = appDic["name"] as String
                        thePost.fromApp = theApp
                    }
                    
                    i++
                }
                var saveError : NSError?
                CoreDataManager.sharedInstance.saveContexts()
                dispatch_async(dispatch_get_main_queue(), completionBlock)
            })
        }
    }
}

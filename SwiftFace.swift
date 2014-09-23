//
//  SwiftFace.swift
//  SwiftFace
//
//  Created by Dmitry Goncharenko on 8/26/14.
//  Copyright (c) 2014 Dmitry Goncharenko. All rights reserved.
//

/**
*  CORE DATA MODELS
*/

import Foundation
import CoreData
import UIkit

extension NSManagedObject {
    class func checkExistingObject(entityName: String, propertyName: String, propertyValue: String, context: NSManagedObjectContext) -> AnyObject? {
        let request : NSFetchRequest = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%@ = %@", propertyName, propertyValue)
        var error: NSError? = nil
        var matches: NSArray = context.executeFetchRequest(request, error: &error)!
        if (matches.count > 0) {
            // handle error
            return matches[0]
        }
        return nil
    }
}

// =============
// USER
// ============

class FacebookUser: NSManagedObject {
    @NSManaged var facebookUserID: NSString
    @NSManaged var userName: NSString?
    @NSManaged var posts: NSSet?
    var userAvatar: UIImage?
    
    // TODO: rewrite copypaste
    class func createUser (idValue:NSString, context: NSManagedObjectContext) -> FacebookUser {
        let entityName = "FacebookUser"
        
        if let theEntity = NSManagedObject.checkExistingObject(entityName, propertyName: "facebookUserID", propertyValue: idValue, context: context) as? FacebookUser {
            return theEntity
        } else {
            let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
            var myObject : FacebookUser = FacebookUser(entity: entityDescription!, insertIntoManagedObjectContext: context)
            myObject.facebookUserID = idValue
            return myObject
        }
    }
    
    func avatarURL() -> NSURL {
        return NSURL.URLWithString("https://graph.facebook.com/" + self.facebookUserID + "/picture?type=small")
    }

}

// =============
// POST
// ============

class FacebookPost: NSManagedObject {

    @NSManaged var author: FacebookUser
    @NSManaged var created_at: NSDate?
    @NSManaged var facebookPostID: NSString
    @NSManaged var fbMessage: NSString?
    @NSManaged var isLiked: NSNumber
    @NSManaged var likeURL: NSString?
    @NSManaged var fromApp: FacebookApp?
    
    class func allPosts () -> NSFetchedResultsController? {
        // TODO: make with className
        let fRequest = NSFetchRequest()
        if let context = CoreDataManager.sharedInstance.managedObjectContext {
            fRequest.entity = NSEntityDescription.entityForName("FacebookPost", inManagedObjectContext: context)
            fRequest.sortDescriptors = [NSSortDescriptor(key: "facebookPostID", ascending: true)]
            let frc = NSFetchedResultsController(fetchRequest: fRequest,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil)
            return frc
        }
        return nil
    }
    
    class func createFacebookPost (idValue:NSString, context: NSManagedObjectContext) -> FacebookPost {
        let entityName = "FacebookPost"
        if let theEntity = NSManagedObject.checkExistingObject(entityName, propertyName: "facebookPostID", propertyValue: idValue, context: context) as? FacebookPost {
            return theEntity
        } else {
            let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
            var myObject : FacebookPost = FacebookPost(entity: entityDescription!, insertIntoManagedObjectContext: context)
            myObject.facebookPostID = idValue
            return myObject
        }
    }
}

// =============
// APPLICATION
// ============

class FacebookApp: NSManagedObject {
    @NSManaged var appIDString: NSString
    @NSManaged var appName: NSString
    @NSManaged var fbPosts: NSSet?
    
    class func createFacebookApp (idValue: NSString, context: NSManagedObjectContext) -> FacebookApp {
        let entityName = "FacebookApp"
        if let theEntity = NSManagedObject.checkExistingObject(entityName, propertyName: "appIDString", propertyValue: idValue, context: context) as? FacebookApp {
            return theEntity
        } else {
            let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
            let myObject = FacebookApp(entity: entityDescription!, insertIntoManagedObjectContext: context)
            myObject.appIDString = idValue
            return myObject
        }
    }
}

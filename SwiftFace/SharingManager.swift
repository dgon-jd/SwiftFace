//
//  SharingManager.swift
//  SwiftFace
//
//  Created by Dmitry Goncharenko on 8/20/14.
//  Copyright (c) 2014 Dmitry Goncharenko. All rights reserved.
//

import Foundation
import Accounts
import Social

class SharingManager {
    class var readAccessNotificationKey : String {
        return "ReadAccessGranted"
    }
    var faceBookAccount : ACAccount?
    
    private let facebookAppId                            = "257504047781867"
    var readAccessGranted : Bool                 = false

    lazy var accountStore : ACAccountStore       = ACAccountStore()
    lazy var accountTypeFacebook : ACAccountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)

    var userAvatar: UIImage?
    
    class var sharedInstance: SharingManager {
        struct Static {
            static let instance : SharingManager = SharingManager()
        }
        return Static.instance
    }
    
    func getReadAccess() {
        
        let facebookOptions: [NSObject : AnyObject] = [ACFacebookAppIdKey : facebookAppId,
            ACFacebookPermissionsKey: ["email", "read_stream"],
            ACFacebookAudienceKey: ACFacebookAudienceFriends]
        
        let accessCompletionHandler:ACAccountStoreRequestAccessCompletionHandler = {
            (granted:Bool, error:NSError!) -> () in

            self.readAccessGranted = granted

            if granted {
                println("Access granted!")
                let accountsArray = self.accountStore.accountsWithAccountType(self.accountTypeFacebook)
                self.faceBookAccount = accountsArray.last as? ACAccount
                NSNotificationCenter.defaultCenter().postNotificationName(SharingManager.readAccessNotificationKey, object: nil)
            } else {
                println("Access denied!")
                println("[\(error.description)]")
            }
        }
        accountStore.requestAccessToAccountsWithType(accountTypeFacebook,
            options: facebookOptions,
            completion: accessCompletionHandler)

    }
    
    func postFacebookText (#postedText: String) {
        
    }

    func facebookFeed(completionHander :SLRequestHandler!) {
        if readAccessGranted {

            let parameters = ["access_token" : self.faceBookAccount!.credential.oauthToken]

            let feedURL = NSURL.URLWithString("https://graph.facebook.com/me/feed")
            
            let feedRequest : SLRequest = SLRequest(forServiceType: SLServiceTypeFacebook,
                requestMethod: .GET,
                URL: feedURL,
                parameters: parameters)
            
            feedRequest.performRequestWithHandler(completionHander)
        }
    }
    
    func likeAction(isLike: Bool, likeURL: NSURL!, completionHandler: SLRequestHandler!) {
        let requestMethod : SLRequestMethod = isLike ? .POST : .DELETE
        let request = SLRequest(forServiceType: SLServiceTypeFacebook,
            requestMethod: requestMethod,
            URL: likeURL,
            parameters: nil)
        request.account = self.faceBookAccount
        request.performRequestWithHandler(completionHandler)
        
    }
    
}
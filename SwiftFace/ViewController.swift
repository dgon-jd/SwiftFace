//
//  ViewController.swift
//  SwiftFace
//
//  Created by Dmitry Goncharenko on 8/20/14.
//  Copyright (c) 2014 Dmitry Goncharenko. All rights reserved.
//

/**
*  VIEW CONTROLLER
*/

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var facebookTableView: UITableView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var imageDownloadsInProgress: [NSIndexPath: ImageDownloader] = [:]
    
    lazy var facebookMessagesController : FacebookListController? =  {
        let fmc = FacebookListController(tableView: self.facebookTableView)
        return fmc
    }()

    let dateFormatter : NSDateFormatter = {
        let theDateFormatter = NSDateFormatter()
        theDateFormatter.dateStyle = .MediumStyle
        return theDateFormatter
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "onContentSizeChange:",
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil)

        self.userNameLabel.text = "Loading..."
        
        // Dynamic row height
        self.facebookTableView.estimatedRowHeight = 200
        self.facebookTableView.rowHeight = UITableViewAutomaticDimension
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAccountName", name: SharingManager.readAccessNotificationKey, object: nil)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            SharingManager.sharedInstance.getReadAccess()
        })
        
    }
    
    override func viewDidDisappear(animated: Bool)  {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func onContentSizeChange(notification: NSNotification) {
        self.facebookTableView.reloadData()
    }
    
    func updateAccountName () {
        // Just test dispath_after
        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            var name : String = (SharingManager.sharedInstance.faceBookAccount!.username)
            self.userNameLabel.text = "Current user is \(name)"
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fmc = self.facebookMessagesController {
            if fmc.fetchedPosts()?.count != 0 {
                return fmc.fetchedPosts()!.count
            }
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as CustomCell
        if let fmc = facebookMessagesController {
            if let thePost = fmc.postAtIndexPath(indexPath) {
                cell.configureCell(thePost, dateFormatter:self.dateFormatter)
                if (thePost.author.userAvatar == nil) {
                    if !tableView.dragging && !tableView.decelerating {
                        self.startIconDownload(thePost.author, forIndexPath: indexPath)
                    } else {
                        cell.updateUserAvatar(thePost.author.userAvatar)
                    }
                }
            }
        }
        return cell
    }

    func startIconDownload(fbUser: FacebookUser, forIndexPath: NSIndexPath) {
        var iconDownloader = self.imageDownloadsInProgress[forIndexPath]
        if (iconDownloader == nil) {
            iconDownloader = ImageDownloader()
            iconDownloader!.imageURL = fbUser.avatarURL()
            iconDownloader!.completionBlock = { (theImage: UIImage?) -> Void in
                fbUser.userAvatar = theImage
                var cell = self.facebookTableView.cellForRowAtIndexPath(forIndexPath) as? CustomCell
                cell?.updateUserAvatar(fbUser.userAvatar)
                self.imageDownloadsInProgress.removeValueForKey(forIndexPath)
            }
            self.imageDownloadsInProgress[forIndexPath] = iconDownloader
            iconDownloader!.startDownload()
        }
    }
    
    func loadAvatarsForOnScreenRows() {
        if let fmc = facebookMessagesController {
            if fmc.fetchedPosts()?.count > 0 {
                let visiblePaths = self.facebookTableView.indexPathsForVisibleRows() as [NSIndexPath]
                for indexPath in visiblePaths {
                    let user = fmc.postAtIndexPath(indexPath)!.author
                    if user.userAvatar == nil {
                        self.startIconDownload(user, forIndexPath: indexPath)
                    }
                }
                
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.loadAvatarsForOnScreenRows()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.loadAvatarsForOnScreenRows()
    }
    
    @IBAction func buttonTapped(sender:AnyObject) {
        PostsManager.loadPosts({})
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}


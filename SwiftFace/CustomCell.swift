//
//  CustomCell.swift
//  SwiftFace
//
//  Created by Dmitry Goncharenko on 8/28/14.
//  Copyright (c) 2014 Dmitry Goncharenko. All rights reserved.
//

import Foundation
import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var userAvatarImageView: UIImageView!

    var cellPost : FacebookPost?

    override func awakeFromNib() {
        self.authorNameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        self.messageLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.dateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    }
    
    func configureCell(thePost: FacebookPost!, dateFormatter: NSDateFormatter!) {
        self.cellPost = thePost
        if let authorString = thePost.author.userName {
            self.authorNameLabel.text = authorString
        }
        if let messageString = thePost.fbMessage {
            self.messageLabel.text = messageString
        }
        
        if let dateString = thePost.created_at {
            self.dateLabel.text = dateFormatter.stringFromDate(dateString)
        }
        self.configureLikeButtonTitle()

   }
    
    func updateUserAvatar(userAvatar:UIImage!) {
        self.userAvatarImageView.image = userAvatar
    }
    
    @IBAction func likeButtonTapped(sender: UIButton) {
        if let thePost = self.cellPost {
            var like = thePost.isLiked.boolValue
            if let theUrl = thePost.likeURL {
                PostsManager.likeMessage(!like, likeURL: NSURL.URLWithString(theUrl), complectionBlock: { () -> Void in
                    thePost.isLiked = NSNumber.numberWithBool(!like)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.configureLikeButtonTitle()
                    })
                })
            }
        }
    }
    
    func configureLikeButtonTitle() {
        if let isLiked = self.cellPost?.isLiked.boolValue {
            self.likeButton.enabled = true
            self.likeButton.highlighted = isLiked
        }
    }
    
}
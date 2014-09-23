//
//  ImageDownloader.swift
//  SwiftFace
//
//  Created by Dmitry Goncharenko on 9/9/14.
//  Copyright (c) 2014 Dmitry Goncharenko. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloader: NSObject, NSURLConnectionDataDelegate {
    
    var imageURL: NSURL?
    var activeDownload: NSMutableData
    var imageConnection: NSURLConnection
    
    var completionBlock: ((theImage: UIImage?) -> Void)?
    
    override init () {
        activeDownload = NSMutableData.data()
        imageConnection = NSURLConnection()
        super.init()
    }
    
    func startDownload() {
        if let theURL = imageURL {
            self.activeDownload = NSMutableData.data()
            let request = NSURLRequest(URL: theURL)
            let conn = NSURLConnection(request: request, delegate: self)
            
            self.imageConnection = conn
        }
    }
    
    private func resetToDefaults() {
        self.activeDownload = NSMutableData.data()
        self.imageConnection = NSURLConnection()
    }
    
    func cancelDownload() {
        self.imageConnection.cancel()
        self.resetToDefaults()
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.activeDownload.appendData(data)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.resetToDefaults()
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        var image = UIImage(data: self.activeDownload)
        self.resetToDefaults()
        if let theBlock = self.completionBlock {
            theBlock(theImage: image)
        }
    }
}
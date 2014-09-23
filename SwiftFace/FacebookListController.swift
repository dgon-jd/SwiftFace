//
//  FacebookListController.swift
//  SwiftFace
//
//  Created by Dmitry Goncharenko on 8/26/14.
//  Copyright (c) 2014 Dmitry Goncharenko. All rights reserved.
//

import Foundation
import CoreData

/**
*  MANAGE FETCHED DATA
*/
import UIKit

class FacebookListController: NSFetchedResultsControllerDelegate{
   
    private let tableView: UITableView
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.reloadRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)  {
        self.tableView.endUpdates()
    }
    private lazy var facebookListController : NSFetchedResultsController? = {
        if let frc = FacebookPost.allPosts() {
            frc.delegate = self
            frc.performFetch(nil)
            return frc
        }
        return  nil
        }()

    func fetchedPosts() -> [FacebookPost]? {
        if let frc = self.facebookListController {
            let metaData = frc.fetchedObjects as? [FacebookPost]
            return metaData
        }
        return nil
    }
    
    func postAtIndexPath(indexPath: NSIndexPath) -> FacebookPost? {
        let sectionInfo = 0
        if let frc = self.facebookListController {
            if frc.fetchedObjects?.count > 0 {
                let metaData = frc.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as FacebookPost
            return metaData
            }
        }
        return nil
    }
    
    func reloadData() {
        if let frc = self.facebookListController  {
            frc.performFetch(nil)
        }
    }
}
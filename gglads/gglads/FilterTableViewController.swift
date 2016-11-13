//
//  FilterTableViewController.swift
//  gglads
//
//  Created by Andrey on 13.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class FilterTableViewController: UITableViewController
{
    
    lazy var fetchResultsController : NSFetchedResultsController =
    {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entity = NSEntityDescription.entityForName("Categorie", inManagedObjectContext: managedObjectContext)
        let req = NSFetchRequest()
        req.sortDescriptors = [ NSSortDescriptor(key: "name", ascending: true)]
        req.predicate = nil
        req.entity = entity
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: req, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        aFetchedResultsController.delegate = self
        
        var e: NSError?
        do {
            try aFetchedResultsController.performFetch()
        } catch var error as NSError {
            e = error
            print("fetch error: \(e!.localizedDescription)")
        } catch {
            fatalError()
        }
        
        return aFetchedResultsController
    }()
}

//MARK: - LifeCycle
extension  FilterTableViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Выберите категорию"
        try? self.fetchResultsController.performFetch()
        self.download()
        // Do any additional setup after loading the view, typically from a nib.
    }
}



//MARK: - Download
extension FilterTableViewController
{
    func download()
    {
        CategorieManager.getCategories(success: { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                try? self.fetchResultsController.performFetch()
                self.tableView.reloadData()
            })
            }) { () -> Void in
                
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension FilterTableViewController
{
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let sectionInfo : [NSFetchedResultsSectionInfo]?
        sectionInfo = self.fetchResultsController.sections
        if sectionInfo != nil
        {
            if (sectionInfo![indexPath.section]).numberOfObjects != 0
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("category", forIndexPath: indexPath)
                cell.textLabel?.text = (self.fetchResultsController.objectAtIndexPath(indexPath) as! Categorie).name
                return cell
            }
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("category", forIndexPath: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = self.fetchResultsController.sections
        {
            let rows = sections[section].numberOfObjects
            if rows != 0
            {
                return rows
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        let sectionInfo : [NSFetchedResultsSectionInfo]?
        sectionInfo = self.fetchResultsController.sections
        if sectionInfo != nil
        {
            if (sectionInfo![indexPath.section]).numberOfObjects != 0
            {
                self.filtering(self.fetchResultsController.objectAtIndexPath(indexPath) as! Categorie)
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
        return indexPath
    }
}
//MARK: - Filter to Main
extension FilterTableViewController
{
    func filtering(categorie : Categorie)
    {
        let vc = self.navigationController?.viewControllers[0] as? MainViewController
        if let vc = vc
        {
            vc.title = categorie.name
            vc.categorie = categorie
            vc.categoryId = categorie.id
            vc.fetchResultsController.delegate = nil
            vc.fetchResultsController = vc.createFetchController()
            vc.tableView.reloadData()
            vc.download()
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension FilterTableViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if #available(iOS 9, *) {
            self.tableView.beginUpdates()
        }
    }
    
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if #available(iOS 9, *) {
            switch type {
            case .Insert:
                if let newIndexPath = newIndexPath where newIndexPath.row != indexPath?.row {
                    self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
                }
            case .Update:
                return
            case .Move:
                if let newIndexPath = newIndexPath, indexPath = indexPath where newIndexPath != indexPath {
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
                }
            case .Delete:
                if let indexPath = indexPath {
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if #available(iOS 9, *) {
            self.tableView.endUpdates()
        }
    }
}
  
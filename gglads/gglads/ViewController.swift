//
//  ViewController.swift
//  gglads
//
//  Created by Andrey on 12.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import UIKit
import CoreData
class MainViewController: UITableViewController
{
    var categorie : Categorie?
    var categoryId : Int64 = 1
    var notificationCount : Int = 0
    var notificationDescription = ""
    
    lazy var fetchResultsController : NSFetchedResultsController = self.createFetchController()
    
    func createFetchController() -> NSFetchedResultsController
    {
        let managedObjectContext = ProductManager.nonProductPersistentContext
        let entity = NSEntityDescription.entityForName("Product", inManagedObjectContext: managedObjectContext)
        let req = NSFetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        req.predicate = NSPredicate(format: "categoryId=%d", categoryId)
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
    }
}

//MARK: - LifeCycle
extension  MainViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let nibProduct = UINib (nibName: "ProductCell", bundle: nil)
        self.tableView.registerNib(nibProduct, forCellReuseIdentifier: "Product")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.tableView.backgroundColor = .whiteColor()
        
        self.title = "Tech"
        self.createLeftRightBarButtons()
        try? self.fetchResultsController.performFetch()
        self.download()
        
        NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector:  Selector("download"), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
}
//MARK: - Create BarButton Button
extension MainViewController
{
    func createLeftRightBarButtons()
    {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Filter"), style: UIBarButtonItemStyle.Plain, target: self, action: "showFilter")
    }
}
//MARK: - Segue
extension MainViewController
{
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "showDetail"
        {
            let vc = segue.destinationViewController as? ProductViewController
            if let indexPath = sender as? NSIndexPath
            {
                vc?.product = self.fetchResultsController.objectAtIndexPath(indexPath) as? Product
            }
        }
    }
    
    func showFilter()
    {
        self.performSegueWithIdentifier("showFilter", sender: self)
    }
}

//MARK: - Refresh and Download
extension MainViewController
{
    func refresh( sender : UIRefreshControl )
    {
        print("refreshin....")
        self.download()
        sender.endRefreshing()
    }
    
    func download()
    {
        var categorieSearch = "tech"
        if let categorie = categorie
        {
            categorieSearch = categorie.slug
        }
        ProductManager.getProducts(categorie: categorieSearch, success: { () -> Void in 
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                try? self.fetchResultsController.performFetch()
                self.tableView.reloadData()
            })
            }) { () -> Void in
                
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension MainViewController
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
                let cell = tableView.dequeueReusableCellWithIdentifier("Product", forIndexPath: indexPath) as! ProductCell
                cell.configureSelfWithDataModel(self.fetchResultsController.objectAtIndexPath(indexPath) as! Product)
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Product", forIndexPath: indexPath) as! ProductCell
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
        self.performSegueWithIdentifier("showDetail", sender: indexPath)
        return indexPath
    }
}

extension MainViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        notificationCount = 0
        
        if #available(iOS 9, *) {
            self.tableView.beginUpdates()
        }
    }
    
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
        if type == .Insert
        {
            notificationCount++
            if let product = anObject as? Product
            {
                self.notificationDescription = product.descriptionProduct
            }
        }
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
        switch notificationCount
        {
            case 0:
                return
            case 1:
                let alert = UIAlertController(title: "Появился новый продукт", message: notificationDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                break
            default :
                let alert = UIAlertController(title: "Появились новые продукты", message: "Количество новых продуктов равно \(notificationCount)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                break
            
        }
    }
}


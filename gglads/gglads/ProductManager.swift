//
//  ProductManager.swift
//  gglads
//
//  Created by Andrey on 13.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import Foundation
import CoreData
class ProductManager : QueueManager
{
    static var getProductOperation : ProductOperation?
    
    static var nonProductPersistentContext : NSManagedObjectContext = {
        let mainContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let privateContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        privateContext.parentContext = mainContext
        return privateContext
    }()
}

extension ProductManager
{
    class func getProducts(categorie categorie : String, success: () -> Void,failure : ()->Void)
    {
        print("init")
        self.getProductOperation?.cancel()
        self.getProductOperation = ProductOperation(categorie : categorie,failure: { () -> Void in
                failure()
            }, success: { (products) -> Void in
                success()
        })
        super.queue.maxConcurrentOperationCount = 1
        super.queue.addOperation(self.getProductOperation!)
        print("queued")
        
    }
}
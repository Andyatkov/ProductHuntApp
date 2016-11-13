//
//  CategorieOperation.swift
//  gglads
//
//  Created by Andrey on 13.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class CategorieOperation : NSOperation
{
    var internetTask:Request?
    var successBlock : () -> Void
    var failureBlock : () -> Void
    init(
        failure: () -> Void,
        success: () -> Void
        ) {
            self.successBlock = success
            self.failureBlock = failure
            super.init()
    }
    
    override func cancel()
    {
        internetTask?.cancel()
        super.cancel()
        print("operation cancel \(self)")
    }
    
    let categorieManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func main()
    {
        let semaphore = dispatch_semaphore_create(0)
        
        internetTask = ApiClient.sharedInstance.getCategorie(success: { (categories) -> Void in
            
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.parentContext = self.categorieManagedObjectContext
            
            privateContext.performBlockAndWait({ () -> Void in
                if let categories = categories["categories"].array
                {
                    
                    for categorie in categories
                    {
                        if ( self.cancelled ) {
                            return
                        }
                        
                        let id = categorie["id"].int64Value
                        let name = categorie["name"].stringValue
                        let slug = categorie["slug"].stringValue
                        CategorieFabric.createOrUpdateCategorie(id, name: name, slug: slug, context: privateContext)
                    }
                }
                if ( self.cancelled != true )
                {
                    var e: NSError?
                    do {
                        try privateContext.save()
                    } catch let error as NSError {
                        e = error
                        
                    } catch {
                    }
                }
                self.successBlock()
                dispatch_semaphore_signal(semaphore)
            })
            }, failure: { () -> Void in
                self.failureBlock()
                dispatch_semaphore_signal(semaphore)
        })
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
}

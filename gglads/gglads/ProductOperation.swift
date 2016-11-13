//
//  ProductOperation.swift
//  gglads
//
//  Created by Andrey on 13.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class ProductOperation : NSOperation
{
    var internetTask:Request?
    var categorie : String
    var successBlock : () -> Void
    var failureBlock : () -> Void
    init(
        categorie : String,
        failure: () -> Void,
        success: () -> Void
        ) {
            self.categorie = categorie
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
    
     let productManagedObjectContext = ProductManager.nonProductPersistentContext
    
    override func main()
    {
        let semaphore = dispatch_semaphore_create(0)
        internetTask = ApiClient.sharedInstance.getProduct(categorie : self.categorie, success: { (products) -> Void in
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.parentContext = self.productManagedObjectContext
            
            privateContext.performBlockAndWait({ () -> Void in
                if let posts = products["posts"].array
                {
                    
                    for post in posts
                    {
                        if ( self.cancelled ) {
                            return
                        }
                        let id = post["id"].int64Value
                        let categoryId = post["category_id"].int64Value
                        let name = post["name"].stringValue
                        let description = post["tagline"].stringValue
                        let votes_count = post["votes_count"].int64Value
                        let screenshotUrl = post["screenshot_url"]["850px"].stringValue
                        let smallScreenshotUrl  = post["screenshot_url"]["300px"].stringValue
                        let site = post["redirect_url"].stringValue
                        
                        let idPhoto = post["thumbnail"]["id"].int64Value
                        let media_type = post["thumbnail"]["media_type"].stringValue
                        let image_url = post["thumbnail"]["image_url"].stringValue
                        let thumbnail = ThumbnailFabric.createOrUpdateThumbnail(idPhoto, media_type: media_type, image_url: image_url, context: privateContext)
                        ProductFabric.createOrUpdateProduct(id,categoryId : categoryId, name: name, descriptionProduct: description, upVotes: votes_count, smallScreenshotUrl: smallScreenshotUrl, screenshotUrl: screenshotUrl, site: site, thumbnail: thumbnail, context: privateContext)
                        
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
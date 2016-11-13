//
//  ProductFabric.swift
//  gglads
//
//  Created by Andrey on 13.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import CoreData

class ProductFabric
{
    class func createOrUpdateProduct(
        id : Int64,
        categoryId : Int64,
        name : String,
        descriptionProduct : String,
        upVotes : Int64,
        smallScreenshotUrl : String,
        screenshotUrl : String,
        site : String,
        thumbnail : Thumbnail,
        context : NSManagedObjectContext) -> Product
    {
        let entityName = "Product"
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id=%d", id)
        let uiContext = context
        let fetchResults = ( try? uiContext.executeFetchRequest(fetchRequest)) as? [Product]
        
        
        if (fetchResults?.count == 1)
        {
            let productResult = (fetchResults![0])
            productResult.name = name
            productResult.categoryId = categoryId
            productResult.descriptionProduct = descriptionProduct
            productResult.upVotes =  upVotes
            productResult.smallScreenshotUrl = smallScreenshotUrl
            productResult.screenshotUrl = screenshotUrl
            productResult.site = site
            productResult.thumbnail = thumbnail
            
            return productResult
        }
        else
        {
            let productResult = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: uiContext) as! Product
            productResult.id = id
            productResult.categoryId = categoryId
            productResult.name = name
            productResult.descriptionProduct = descriptionProduct
            productResult.upVotes =  upVotes
            productResult.smallScreenshotUrl = smallScreenshotUrl
            productResult.screenshotUrl = screenshotUrl
            productResult.site = site
            productResult.thumbnail = thumbnail
            
            return productResult
        }
    }
}

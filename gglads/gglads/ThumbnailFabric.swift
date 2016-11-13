//
//  ThumbnailFabric.swift
//  gglads
//
//  Created by Andrey on 13.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import CoreData

class ThumbnailFabric
{
    class func createOrUpdateThumbnail(
        id : Int64,
        media_type : String,
        image_url : String,
        context : NSManagedObjectContext) -> Thumbnail
    {
        let entityName = "Thumbnail"
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id=%d", id)
        let uiContext = context
        let fetchResults = ( try? uiContext.executeFetchRequest(fetchRequest)) as? [Thumbnail]
        
        
        if (fetchResults?.count == 1)
        {
            let thumbnailResult = (fetchResults![0])
            thumbnailResult.media_type = media_type
            thumbnailResult.image_url = image_url
            
            return thumbnailResult
        }
        else
        {
            let thumbnailResult = NSEntityDescription.insertNewObjectForEntityForName("Thumbnail", inManagedObjectContext: uiContext) as! Thumbnail
            thumbnailResult.id = id
            thumbnailResult.media_type = media_type
            thumbnailResult.image_url = image_url
            
            return thumbnailResult
        }
    }
}

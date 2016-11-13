//
//  Product.swift
//  gglads
//
//  Created by Andrey on 13.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import CoreData

class Product : NSManagedObject
{
    @NSManaged var id : Int64
    @NSManaged var categoryId : Int64
    @NSManaged var name : String
    @NSManaged var descriptionProduct : String
    @NSManaged var upVotes : Int64
    @NSManaged var smallScreenshotUrl : String
    @NSManaged var screenshotUrl : String
    @NSManaged var site : String
    @NSManaged var thumbnail : Thumbnail
}
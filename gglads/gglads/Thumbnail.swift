//
//  Thumbnail.swift
//  gglads
//
//  Created by Andrey on 13.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import CoreData

class Thumbnail : NSManagedObject
{
    @NSManaged var id : Int64
    @NSManaged var media_type : String
    @NSManaged var image_url : String
}
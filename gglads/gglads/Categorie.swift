//
//  Categorie.swift
//  gglads
//
//  Created by Andrey on 13.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import CoreData

class Categorie : NSManagedObject
{
    @NSManaged var id : Int64
    @NSManaged var slug : String
    @NSManaged var name : String
}
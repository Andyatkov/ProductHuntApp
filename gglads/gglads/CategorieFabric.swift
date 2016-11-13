//
//  CategorieFabric.swift
//  gglads
//
//  Created by Andrey on 13.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import CoreData

class CategorieFabric
{
    class func createOrUpdateCategorie(
        id: Int64,
        name: String,
        slug: String,
        context : NSManagedObjectContext) -> Categorie
    {
            let entityName = "Categorie"
            let fetchRequest = NSFetchRequest(entityName: entityName)
            fetchRequest.predicate = NSPredicate(format: "id=%d", id)
            let uiContext = context
            let fetchResults = ( try? uiContext.executeFetchRequest(fetchRequest)) as? [Categorie]
        
            
            if (fetchResults?.count == 1)
            {
                let categorieResult = (fetchResults![0])
                categorieResult.name = name
                categorieResult.slug = slug
                return categorieResult
            }
            else
            {
                let newCategorie = NSEntityDescription.insertNewObjectForEntityForName("Categorie", inManagedObjectContext: uiContext) as! Categorie
                
                newCategorie.id = id
                newCategorie.name = name
                newCategorie.slug = slug
                return newCategorie
            }
    }
}
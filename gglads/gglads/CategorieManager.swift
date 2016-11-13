//
//  CategorieManager.swift
//  gglads
//
//  Created by Andrey on 13.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import Foundation

class CategorieManager : QueueManager
{
    static var getCategorieOperation : CategorieOperation?
}

extension CategorieManager
{
    class func getCategories(success success: () -> Void,failure : ()->Void)
    {
        print("init")
        self.getCategorieOperation?.cancel()
        self.getCategorieOperation = CategorieOperation(failure: { () -> Void in
                failure()
            }, success: { () -> Void in
                success()
        })
        super.queue.maxConcurrentOperationCount = 1
        super.queue.addOperation(self.getCategorieOperation!)
        print("queued")
        
    }
}

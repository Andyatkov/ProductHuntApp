//
//  QuequeManager.swift
//  gglads
//
//  Created by Andrey on 13.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import UIKit

class QueueManager {
    static var queue:OperationQueue = OperationQueue()
}

class OperationQueue: NSOperationQueue {
    override func cancelAllOperations() {
        super.cancelAllOperations()
        print("cancel: operations in queue: \(self.operations.count) \(self.operations as NSArray)")
    }
    
    override func addOperation(op: NSOperation) {
        super.addOperation(op)
        print("added:  operations in queue: \(self.operations.count) \(self.operations as NSArray)")
    }
}




extension NSOperation {
    override public var description : String {
        return "\(super.description)\(self.cancelled ? "-CANCELLED" : "")"
    }
}

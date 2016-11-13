//
//  API_CLIENT.swift
//  gglads
//
//  Created by Andrey on 12.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//


import Foundation
import Alamofire



extension Request {
    func responseJSONInBackground (
        options options: NSJSONReadingOptions = .AllowFragments,
        completionHandler: (NSURLRequest?, NSHTTPURLResponse?, Result<AnyObject>) -> Void)
        -> Self {
            return response(queue: dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), responseSerializer: Request.JSONResponseSerializer(), completionHandler: completionHandler)
    }
}



class ApiClient {
    
    typealias RequestSuccess = (AnyObject?) -> Void
    typealias RequestFailure = () -> Void

    
    static let ERROR_CODE_UNKNOWN = 110
    static let ERROR_CODE_WRONG_OR_MISSING_JSON = 111
    static let ERROR_CODE_MISSING_SUCCESS_FIELD = 112
    static let ERROR_CODE_SERVER_REASON = 113
    static let ERROR_CODE_REGISTRATION_MISSING_POINTS = 114
    static let ERROR_CODE_UPDATE_INFO_FAILED = 115
    
    static let sharedInstance = ApiClient()
    
    var manager = AlamofireCustomManager.sharedInstance
    var screenSize = UIScreen.mainScreen().bounds.size
    var networkActivityCounter = 0
    
    init() {
        screenSize.width = screenSize.width
        screenSize.height = screenSize.height
    }
    
    
    
    private func setNetworkActivityIndicatorTo(visible visible: Bool) {
        if visible {
            networkActivityCounter += 1
        }
        else {
            networkActivityCounter -= 1
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = (networkActivityCounter > 0)
    }
    
    private func get(url: String, callback: (payload: AnyObject?, error: AnyObject?) -> Void)->Request {
        //let manager = AlamofireCustomManager.createManager()
        setNetworkActivityIndicatorTo(visible: true)
        
        let request = manager.request(.GET, url)
        request.responseJSONInBackground {(request, response, result)-> Void in
            self.setNetworkActivityIndicatorTo(visible: false)
            
            print("\(result.error.debugDescription)")
            if(result.error == nil)
            {
                callback(payload: result.value, error: nil)
            }
            else
            {
                callback(payload: nil, error:nil)
            }
            
        }
        return request
    }
    
    
    private func post(url: String, parameters: [String: AnyObject], callback: (payload: AnyObject?, error: AnyObject?) -> Void) {
        //let manager = AlamofireCustomManager.createManager()
        setNetworkActivityIndicatorTo(visible: true)
        
        let request = manager.request(.POST, url, parameters: parameters, encoding: .URL)
        request.responseJSON{(request, response, result)-> Void in
            self.setNetworkActivityIndicatorTo(visible: false)
            
            if result.error == nil {
                callback(payload: result.value, error: nil)
            } else {
                print(result.error)
                callback(payload: nil, error: nil )
            }
        }
    }
    private func postJSON(url: String, parameters: [String: AnyObject], callback: (payload: AnyObject?, error: AnyObject?) -> Void)->Request {
        setNetworkActivityIndicatorTo(visible: true)
        //let manager = AlamofireCustomManager.createManager()
        let request = manager.request(.POST, url, parameters: parameters, encoding: .JSON)
        request.responseJSON{(request, response, result)-> Void in
            self.setNetworkActivityIndicatorTo(visible: false)
            
            print(result)
            if result.error == nil {
                callback(payload: result.value, error: nil)
            } else {
                print(result.error)
                callback(payload: nil, error: result.value)
            }
        }
        return request
    }
    
    private func delete(url: String, callback: (payload: AnyObject?, error: AnyObject?) -> Void)->Request {
        setNetworkActivityIndicatorTo(visible: true)
        //let manager = AlamofireCustomManager.createManager()
        let request = manager.request(.DELETE, url)
        //let request = manager.request(.DELETE, url, parameters: parameters, encoding: .JSON)
        request.responseJSON{(request, response, result)-> Void in
            self.setNetworkActivityIndicatorTo(visible: false)
            
            if result.error == nil {
                callback(payload: result.value, error: nil)
            } else {
                print(result.error)
                callback(payload: nil, error: nil )
            }
        }
        return request
    }
    
    private func postMultipart(url: String, data : NSData?, parameters: [String: AnyObject], callback: (payload: AnyObject?, error: AnyObject?) -> Void) {
        setNetworkActivityIndicatorTo(visible: true)
        //let manager = AlamofireCustomManager.createManager()
        let request = manager.upload(.POST, url, multipartFormData: { (multipartFormData) -> Void in
            
            if let data = data {
                multipartFormData.appendBodyPart(data: data, name: "photo", fileName: "image.jpg", mimeType: "image/jpg")
            }
            
            for (key, value) in parameters {
                multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
            }
            }) { (encodingResult) -> Void in
                self.setNetworkActivityIndicatorTo(visible: false)
                
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON {(request, response, result) -> Void in
                        print(result.error.debugDescription)
                        if result.error == nil {
                            callback(payload: result.value, error: nil)
                        } else {
                            callback(payload: nil, error: nil)
                        }
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
        }
    }
    
    private func postMultipart(url: String, data : NSData?, callback: (payload: AnyObject?, error: AnyObject?) -> Void) {
        setNetworkActivityIndicatorTo(visible: true)
        //let manager = AlamofireCustomManager.createManager()
        let request = manager.upload(.POST, url, multipartFormData: { (multipartFormData) -> Void in
            
            if let data = data {
                multipartFormData.appendBodyPart(data: data, name: "photo", fileName: "image.jpg", mimeType: "image/jpg")
            }
            }) { (encodingResult) -> Void in
                self.setNetworkActivityIndicatorTo(visible: false)
                
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON {(request, response, result) -> Void in
                        print(result.error.debugDescription)
                        if result.error == nil {
                            callback(payload: result.value, error: nil)
                        } else {
                            callback(payload: nil, error: nil)
                        }
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
        }
    }
    
    private func put(url: String, parameters: [String: AnyObject], callback: (payload: AnyObject?, error: AnyObject?) -> Void) {
        setNetworkActivityIndicatorTo(visible: true)
        //let manager = AlamofireCustomManager.createManager()
        let request = manager.request(.PUT, url, parameters: parameters, encoding: .JSON)
        request.responseJSON { (request, response, result) -> Void in
            self.setNetworkActivityIndicatorTo(visible: false)
            
            if result.error == nil {
                callback(payload: result.value, error: nil)
            } else {
                print(result.error)
                callback(payload: nil, error: nil)
            }
        }
    }
    
    private func put(url: String, callback: (payload: AnyObject?, error: AnyObject?) -> Void) {
        setNetworkActivityIndicatorTo(visible: true)
        //let manager = AlamofireCustomManager.createManager()
        let request = manager.request(.PUT, url, encoding: .JSON)
        request.responseJSON { (request, response, result) -> Void in
            self.setNetworkActivityIndicatorTo(visible: false)
            
            if result.error == nil {
                callback(payload: result.value, error: nil)
            } else {
                print(result.error)
                callback(payload: nil, error: nil)
            }
        }
    }
}

extension ApiClient
{
    func getProduct(categorie categorie : String, success : (products : JSON) -> Void,failure : RequestFailure)->Request
    {
        let url = Constant.HOST_URL + "/v1/categories/\(categorie)/posts"
        
        
        let request = self.get(url) { (payload, error) -> Void in
            if error != nil {
                failure()
            } else if (payload != nil ? JSON(payload!) : nil) != nil
            {
                success(products: JSON(payload!))
            } else {
                failure()
            }
        }
        return request
    }
}

extension ApiClient
{
    func getCategorie(success success : (categorie : JSON) -> Void,failure : RequestFailure)->Request
    {
        let url = Constant.HOST_URL + "/v1/categories"
        
        
        let request = self.get(url) { (payload, error) -> Void in
            if error != nil {
                failure()
            } else if (payload != nil ? JSON(payload!) : nil) != nil
            {
                success(categorie: JSON(payload!))
            } else {
                failure()
            }
        }
        return request
    }
}
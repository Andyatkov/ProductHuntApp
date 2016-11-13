//
//  AlomofireCustomManager.swift
//  gglads
//
//  Created by Andrey on 13.11.16.
//  Copyright © 2016 DyatkovAndrey. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireCustomManager {
    static let token = "591f99547f569b05ba7d8777e2e0824eea16c440292cce1f8dfb3952cc9937ff"
    static let sharedInstance = AlamofireCustomManager.createManager()
    
    class func createManager() -> Manager {
        var defaultAdditionalHeaders = Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        defaultAdditionalHeaders["Accept"] = Constant.ACCEPT
        defaultAdditionalHeaders["Content-Type"] = Constant.ContentType
        defaultAdditionalHeaders["Authorization"] = Constant.BEARER + " " + token
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            Constant.HOST_URL: .PerformDefaultEvaluation(validateHost: true)
            //.PinCertificates(certificates: ServerTrustPolicy.certificatesInBundle(), validateCertificateChain: true, validateHost: true)
        ]
        
        configuration.HTTPAdditionalHeaders = defaultAdditionalHeaders
        return Manager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
    }
}

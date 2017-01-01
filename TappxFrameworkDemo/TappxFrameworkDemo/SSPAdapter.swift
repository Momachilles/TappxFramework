//
//  SSPAdapter.swift
//  TappxFrameworkDemo
//
//  Created by David Alarcon on 26/12/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import TappxFramework

class SSPAdapter: NSObject, TappxAdapter {

    var adapterId: String = "com.tappx.sdk.android.mobileads.SSP.Banner"
    
    enum SSPAdapterError: ErrorType {
        case GeneralError(String)
    }
    
    func adapt(step: TappxMediatorStep, completion: (NSError?) -> ()) {
    
        let raiseError: (ErrorType) -> () = { error in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { 
                let info = [NSLocalizedDescriptionKey: "\(error)"]
                let error = NSError(domain: "com.tappx.TappxFramework", code: -102, userInfo: info)
                completion(error)
            })
            
        }
        
        let taskCompletion: (NSData?, NSURLResponse?, NSError?) -> () = { (data, response, error) in

            if let error = error {
                raiseError(error)
            }
            
            guard let response = response as? NSHTTPURLResponse else {
                return raiseError(SSPAdapterError.GeneralError("Bad Response in SSP Adapter") as NSError)
            }
            
            guard let content = response.allHeaderFields["x-content"] as? String else { return raiseError(SSPAdapterError.GeneralError("Bad content header in SSP Adapter") as NSError) }
            
            switch response.statusCode {
            case 200:
                completion(.None)
            case 204:
                if content == "no_fill" { raiseError(SSPAdapterError.GeneralError("No fill in SSP Adapter")) }
                else { raiseError(SSPAdapterError.GeneralError("Bad content value in SSP Adapter")) }
            case 400:
                guard let reason = response.allHeaderFields["x-error-reason"] as? String else { return raiseError(SSPAdapterError.GeneralError("Bad error reason header in SSP Adapter")) }
                raiseError(SSPAdapterError.GeneralError(reason))
                //completion(.none)
            default:
                return raiseError(SSPAdapterError.GeneralError("Bad status code (\(response.statusCode)) in SSP Adapter"))
            }
        }

        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        guard let url = NSURL(string: "https://ssp.api.tappx.com/dev/puressp.php") else { return raiseError(SSPAdapterError.GeneralError("URL not found")) }
        guard let data = step.e[.data] else { return raiseError(SSPAdapterError.GeneralError("Data not found")) }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let paramString = "data=\(data)"
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request, completionHandler: taskCompletion)
        task.resume()
    }
    
}

extension SSPAdapter: NSURLSessionDelegate {
    func urlSession(session: NSURLSession, didReceive challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        print("Challenge Received: \(challenge)")
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if challenge.protectionSpace.host == "ssp.api.tappx.com" {
                guard let server = challenge.protectionSpace.serverTrust else { return }
                let credential = NSURLCredential(trust: server)
                completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
            }
        }
    }
    
}

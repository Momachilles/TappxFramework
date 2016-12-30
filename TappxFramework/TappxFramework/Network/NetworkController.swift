//
//  NetworkController.swift
//  AdServerTappxFramework
//
//  Created by David Alarcon on 13/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation

struct NetworkConstants {
    private static let kProtocol = "https"
    static let kHostname = "ssp.api.tappx.com"
    static let kNoFill = "no_fill"
    static var kBaseURL: String { return kProtocol + "://" + kHostname }
}

enum NetworkEndpoint: String {
    
    case requestAd = "/dev/mon_v1"
    
    func path() -> String {
        return self.rawValue
    }
    
}

typealias TaskResult = Result<(data: NSData, headers: ResponseHeaders, type: TappxResponseType)>
typealias TaskFuture = Future<(data: NSData, headers: ResponseHeaders, type: TappxResponseType)>
typealias TaskCompletion = (NSData?, NSURLResponse?, NSError?) -> ()

enum TaskError: ErrorType {
    case offline
    case noData
    case noFill
    case badResponse
    case badRequest
    case badStatusCode(Int, String)
    case other(NSError)
}

class NetworkController: NSObject, Reachable {
    
    var configuration: NSURLSessionConfiguration
    
    override init() {
        self.configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        super.init()
    }
    
    func data(for request: TappxRequest, configuration: NSURLSessionConfiguration? = .None) -> TaskFuture {
        
        let session = NSURLSession(configuration: configuration ?? self.configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        let future: TaskFuture = Future() { completion in
            
            let fulfill: (result: TaskResult) -> () = { [weak session] taskResult in
                completion(taskResult)
                session?.finishTasksAndInvalidate()
            }
            
            let completion: TaskCompletion = { (data, response, error) in
                
                print("Data: \(data)")
                print("Response: \(response)")
                print("Error: \(error)")
                
                guard let data = data else {
                    guard let error = error else { return fulfill(result: .failure(TaskError.noData)) }
                    return fulfill(result: .failure(TaskError.other(error)))
                }
                
                guard let response = response as? NSHTTPURLResponse else {
                    return fulfill(result: .failure(TaskError.badResponse))
                }
                
                switch response.statusCode {
                case 200...204:
                    guard let headers = response.allHeaderFields as? [String: AnyObject] else { return fulfill(result: .failure(TaskError.badResponse)) }
                    let respHeaders = ResponseHeaders(from: headers)
                    guard let content = respHeaders.xcontent.value as? String else { return fulfill(result: .failure(TaskError.badResponse)) }
                    if content == NetworkConstants.kNoFill {
                       fulfill(result: .failure(TaskError.noFill))
                    } else {
                        fulfill(result: .success(data: data, headers: respHeaders, type: request.type))
                    }
                default:
                    guard let headers = response.allHeaderFields as? [String: AnyObject] else { return fulfill(result: .failure(TaskError.badResponse)) }
                    let respHeaders = ResponseHeaders(from: headers)
                    fulfill(result: .failure(TaskError.badStatusCode(response.statusCode, respHeaders.xerrorreason.value as? String ?? "")))
                }
            }
            
            guard let request = request.request else { return fulfill(result: .failure(TaskError.badRequest)) }
            let task = session.dataTaskWithRequest(request, completionHandler: completion)
            
            switch self.reachable {
            case .online:
                task.resume()
            case .offline:
                fulfill(result: .failure(TaskError.offline))
            }
            
        }
        
        return future
        
    }
    
    func request(endpoint: NetworkEndpoint, queryParams: TappxQueryStringParameters = TappxQueryStringParameters(), bodyParams: TappxPostBodyParameters = TappxPostBodyParameters.defaultBodyParameters) ->  NSURLRequest? {
        let paramString = queryParams.urlString()
        let urlPath = NetworkConstants.kBaseURL + endpoint.path() + "?" + paramString
        guard let url = NSURL(string: urlPath) else { return .None }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        //JSON
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Mozilla/5.0 (Linux; Android 5.0.1; en-us; SM-N910V Build/LRX22C) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.93 Mobile Safari/537.36", forHTTPHeaderField: "User-Agent")
        do {
            request.HTTPBody = try bodyParams.json()
            return request
        } catch {
            return .None
        }
    }
    
}

extension NetworkController: NSURLSessionDelegate {
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        print("Challenge Received: \(challenge)")
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if challenge.protectionSpace.host == NetworkConstants.kHostname {
                guard let server = challenge.protectionSpace.serverTrust else { return }
                let credential = NSURLCredential(trust: server)
                completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
            }
        }
    }

    
}

extension NetworkController: NSURLSessionDataDelegate {
    func urlSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceive data: NSData) {
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        
    }
    
}

//
//  TappxSignaler.swift
//  AdServerTappxFramework
//
//  Created by David Alarcon on 14/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation
import UIKit

typealias BannerFuture = Future<TappxBanner>
typealias InterstitialFuture = Future<TappxInterstitial>
typealias EventFuture = Future<Bool>
typealias BannerResult = Result<TappxBanner>
typealias InterstitialResult = Result<TappxInterstitial>
typealias EventResult = Result<Bool>

public enum TappxError: ErrorType {
    case noData
    case offline
    case passback
    case mediation(String)
}

extension TappxError {
    init(error: TappxError) {
        switch error {
        case .offline:
            self = TappxError.offline
        case .passback:
            self = TappxError.passback
        case .mediation(let message):
            self = TappxError.mediation(message)
        default:
            self = TappxError.noData
        }
    }
}

extension TappxError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .offline:
            return NSLocalizedString("Connection is Offline", comment: "Connection is Offline")
        case .noData:
            return NSLocalizedString("No Data Received", comment: "No Data Received")
        case .passback:
            return  NSLocalizedString("No ad from Passback", comment: "No ad from Passback")
        case .mediation(let message):
            return  NSLocalizedString("Error in the mediation process: \(message)", comment: "Error in the mediation process: \(message)")
        }
    }
}

final class TappxSignaler: NSObject {
    
    private let controller = NetworkController()
    //private let error: Error? = .none
    
    func bannerFuture(with settings: TappxSettings? = .None, size forcedSize: BannerForcedSize? = .None) -> BannerFuture {
        
        let future: BannerFuture = Future { [unowned self] completion in
            
            ///QueryString
            var qsp = TappxQueryStringParameters()
            if let key = TappxFramework.sharedInstance.clientId { qsp.k = key }
            qsp.at = .banner
            if let size = forcedSize { qsp.fsz = size.rawValue }
            
            //BodyParameters
            //TODO: Fullfill the rest of parameters
            var pbp = TappxPostBodyParameters.defaultBodyParameters
            if let settings = settings {
                pbp.okw = (settings.keywords?.joinWithSeparator(",")) ?? ""
            }
            
            if let location = TappxFramework.sharedInstance.lastPosition {
                pbp.geo = "\(location.latitude),\(location.longitude)"
            }
            
            
            //TODO: QueryParameters!!
            let request: TappxRequest = .advertisement(qsp, pbp)  //self.controller.request(endpoint: .requestAd) else { return completion(.failure(TappxError.noData)) }
            let taskFuture = self.controller.data(for: request)
            print("Type: \(request.type)")
            
            taskFuture.start({ [unowned self] result in
                let bannerResult = result ->> self.banner ->> self.postProcess  //result.flatMap(self.banner)
                //let ppBannerResult = self.postProcessBanner(type: request.type, result: bannerResult)
                completion(bannerResult) //completion(ppBannerResult)
                //self.controller.finishSession()
            })
        }
        
        return future
        
    }
    
    func interstitialFuture(with settings: TappxSettings? = .None, size forcedSize: InterstitialForcedSize? = .None) -> InterstitialFuture {
        
        let future: InterstitialFuture = Future { [unowned self] completion in
            
            ///QueryString
            var qsp = TappxQueryStringParameters()
            if let key = TappxFramework.sharedInstance.clientId { qsp.k = key }
            qsp.at = .interstitial
            if let size = forcedSize { qsp.fsz = size.rawValue }
            
            //BodyParameters
            //TODO: Fullfill the rest of parameters
            var pbp = TappxPostBodyParameters.defaultBodyParameters
            if let settings = settings {
                pbp.okw = (settings.keywords?.joinWithSeparator(",")) ?? ""
            }
            
            pbp.dsw = Int(UIScreen.mainScreen().bounds.width)
            pbp.dsh = Int(UIScreen.mainScreen().bounds.height)
            
            if let location = TappxFramework.sharedInstance.lastPosition {
                pbp.geo = "\(location.latitude),\(location.longitude)"
            }

            let request: TappxRequest = .advertisement(qsp, pbp)  //self.controller.request(endpoint: .requestAd) else { return completion(.failure(TappxError.noData)) }
            let taskFuture = self.controller.data(for: request)
            
            taskFuture.start({ [unowned self] result in
                let interstitialResult = result ->> self.interstitial ->> self.postProcess
                //let ppInterstitialResult = self.postProcessInterstitial(type: request.type, result: interstitialResult)
                completion(interstitialResult)
                //self.controller.finishSession()
            })
        }
        
        return future
        
    }
    
    func eventFuture(with url: NSURL) -> EventFuture {
        
        let future: EventFuture = Future { [unowned self] completion in
            
            ///Request
            let request: TappxRequest = .event(url)
            let taskFuture = self.controller.data(for: request)
            
            taskFuture.start({ [unowned self] result in
                let eventResult = result ->> self.event
                completion(eventResult)
            })
            
        }
        
        return future
        
    }
    
    func mediationFuture(with settings: TappxSettings? = .None, type: QueryAdType) -> EventFuture {
        
        let future: EventFuture = Future { [unowned self] completion in
            
            ///QueryString
            var qsp = TappxQueryStringParameters()
            if let key = TappxFramework.sharedInstance.clientId { qsp.k = key }
            qsp.at = type
            
            //BodyParameters
            //TODO: Fullfill the rest of parameters
            var pbp = TappxPostBodyParameters.defaultBodyParameters
            if let settings = settings {
                pbp.okw = (settings.keywords?.joinWithSeparator(",")) ?? ""
            }
            
            //TODO: QueryParameters!!
            let request: TappxRequest = .advertisement(qsp, pbp)  //self.controller.request(endpoint: .requestAd) else { return completion(.failure(TappxError.noData)) }
            let taskFuture = self.controller.data(for: request)
            print("Type: \(request.type)")
            
            taskFuture.start({ [unowned self] result in
                
                if let value = result.value() {
                    let mediatorFuture = self.futureSyncMediator(from: (data: value.data, headers: value.headers))
                    
                    mediatorFuture.start({ result in
                        completion(result)
                    })
                    
                }
 
            })
        }
        
        return future
        
    }
    
    private func stepFuture(with step: TappxMediatorStep) -> EventFuture {
        
        let future: EventFuture = Future { fullfil in
            guard let adapter = TappxFramework.sharedInstance.adapter(with: step.cn) else { return fullfil(.failure(TappxError.mediation("Adapter not found for [\(step.cn)]"))) }
            adapter.adapt(step, completion: { error in
                if let error = error { fullfil(.failure(TappxError.mediation(error.localizedDescription))) }
                else { fullfil(.success(true)) }
            })
        }
        
        return future
    }
    
    private func banner(from result: (data: NSData, headers: ResponseHeaders, type: TappxResponseType)) -> BannerResult {
        guard let dataString = String(data: result.data, encoding: NSUTF8StringEncoding) else { return .failure(TappxError.noData) }
        return .success(TappxBanner(with: dataString, headers: result.headers, type: result.type))
    }
    
    private func interstitial(from result: (data: NSData, headers: ResponseHeaders, type: TappxResponseType)) -> InterstitialResult {
        guard let dataString = String(data: result.data, encoding: NSUTF8StringEncoding) else { return .failure(TappxError.noData) }
        return .success(TappxInterstitial(with: dataString, headers: result.headers, type: result.type))
    }
    
    private func event(from result: (data: NSData, headers: ResponseHeaders, type: TappxResponseType)) -> EventResult {
        return .success(true)
    }
    
    private func mediator(from result: (data: NSData, headers: ResponseHeaders, type: TappxResponseType)) -> EventResult {
        guard let dataString = String(data: result.data, encoding: NSUTF8StringEncoding) else { return .failure(TappxError.mediation("No data in json")) }
        let ppp = TappxMediationPostProcessor()
        guard let mediator = ppp.postProcess(dataString) as? TappxMediator else { return .failure(TappxError.mediation("Error in parsing mediation json")) }
        
        print("JSON: \(dataString)")
        
        for step in mediator.mediation {
            //print("I need [\(step.cn)] adapter")
            let adapter = TappxFramework.sharedInstance.adapter(with: step.cn)
            
            adapter?.adapt(step, completion: { error in
                
                //if let error = error { .failure(TappxError.mediation("No data in json")) }
                
            })
            
            //print("Exists? \(adapter)")
        }
        
        return .failure(TappxError.mediation("This is a test error"))//.success(true)
    }
    
    private func futureAsyncMediator(from result: (data: NSData, headers: ResponseHeaders)) -> EventFuture {
        let future: EventFuture = Future { fullfil in
            
            let raiseError: (ErrorType) -> () = { error in
                fullfil(.failure(error))
            }
            
            guard let dataString = String(data: result.data, encoding: NSUTF8StringEncoding) else { return raiseError(TappxError.mediation("No data in json")) }
            let ppp = TappxMediationPostProcessor()
            guard let mediator = ppp.postProcess(dataString) as? TappxMediator else { return raiseError(TappxError.mediation("Error in parsing mediation json")) }
            let steps = mediator.mediation.count
            var nsuccess = 0
            
            let processSuccess: () -> () = {
                print("Success future")
                objc_sync_enter(nsuccess)
                nsuccess = nsuccess + 1
                objc_sync_exit(nsuccess)
                if nsuccess == steps { fullfil(.success(true)) }
            }
            
            for step in mediator.mediation {
                let stepFuture = self.stepFuture(with: step)
                print("Future: \(stepFuture)")
                stepFuture.start { result in
                    switch result {
                    case .success:
                        processSuccess()
                    case .failure(let error):
                        raiseError(error)
                    }
                    
                }
            }            
        }
        
        return future
    }
    
    //TODO: Usee OperationQueue, or GCD. not enough time to implement a better approach
    private func futureSyncMediator(from result: (data: NSData, headers: ResponseHeaders)) -> EventFuture {
        
        let future: EventFuture = Future { fullfil in
            
            let raiseError: (ErrorType) -> () = { error in
                fullfil(.failure(error))
            }
            
            guard let dataString = String(data: result.data, encoding: NSUTF8StringEncoding) else { return raiseError(TappxError.mediation("No data in json")) }
            let ppp = TappxMediationPostProcessor()
            guard let mediator = ppp.postProcess(dataString) as? TappxMediator else { return raiseError(TappxError.mediation("Error in parsing mediation json")) }
            let steps = mediator.mediation.count
            
            if steps > 0 {
            self.startAdapter(mediator, step: 0, completion: { error in
                if let error = error {
                    raiseError(TappxError.mediation((error as NSError).localizedDescription))
                } else {
                    fullfil(.success(true))
                }
            })
            }
        }
        
        return future
    }
    
    private func startAdapter(mediator: TappxMediator, step: Int, completion: (ErrorType?) -> ()) {
        
        let steps = mediator.mediation.count
        var index = step
        
        if steps > 0 {
            let step = mediator.mediation[index]
            guard let adapter = TappxFramework.sharedInstance.adapter(with: step.cn) else { return completion(TappxError.mediation("Adapter not found for [\(step.cn)]")) }
            adapter.adapt(step, completion: { error in
                
                if let error = error {
                    completion(error)
                } else {
                    index = index + 1
                    if index < steps {
                        self.startAdapter(mediator, step: index, completion: completion)
                    }
                    
                }
                
            })
        }
        
        
    }

    private func postProcess<T: TappxAdvertisement>(from result: T) -> Result<T> {

        switch result.type {
        case .passback:
            let ppp = TappxPassbackPostProcessor()
            let ok = ppp.postProcess(result.html) as? Bool ?? false
            
            if ok {
                return .success(result)
            } else {
                return .failure(TappxError.passback)
            }
         /*
        case  .mediation:
            
            let ppp = TappxMediationPostProcessor()
            let mediator = ppp.postProcess(data: result.html) as? TappxMediator
            
            print("Json: \(result.html)")
            
            return .success(result)*/
        case .mraid1:
            print("mediator has mraid1")
            print(result.html)
            return .success(result)
            
        case .mraid2:
            print("mediator has mraid2")
            return .success(result)
            
        default:
            return .success(result)
        }
        
    }

}

//
//  TappxAdapter.swift
//  TappxFramework
//
//  Created by David Alarcon on 21/11/2016.
//  Copyright © 2016 4Crew. All rights reserved.
//

import Foundation


public protocol TappxAdapter {
    var adapterId: String { get set }
    func adapt(step: TappxMediatorStep, completion: (NSError?) -> ())
}

public extension TappxAdapter {
    
}

protocol TappxAdapterContainer {
    var adapters: [TappxAdapter] { get }
    func assignAdapters(new adapters: [TappxAdapter])
    func addAdapter(adapter: TappxAdapter)
    func removeAdapter(adapter: TappxAdapter) throws
    func adapter(with id: String) -> TappxAdapter?
}


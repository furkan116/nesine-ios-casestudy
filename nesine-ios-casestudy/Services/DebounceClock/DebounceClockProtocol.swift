//
//  DebounceClockProtocol.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 15.11.2026.
//

import Foundation

protocol DebounceClockProtocol {
    func schedule(after interval: TimeInterval, workItem: DispatchWorkItem)
}

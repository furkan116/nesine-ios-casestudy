//
//  DebounceClock.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 15.11.2026.
//

import Foundation

final class DebounceClock: DebounceClockProtocol {
    func schedule(after interval: TimeInterval, workItem: DispatchWorkItem) {
        DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: workItem)
    }
}

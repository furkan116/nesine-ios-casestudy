//
//  TestDebounceClock.swift
//  nesine-ios-casestudyTests
//
//  Created by Furkan Yıldırım on 15.11.2026.
//

import Foundation
@testable import nesine_ios_casestudy

final class TestDebounceClock: DebounceClockProtocol {

    private var now: TimeInterval = 0
    private var scheduledItems: [(time: TimeInterval, workItem: DispatchWorkItem)] = []

    func schedule(after interval: TimeInterval, workItem: DispatchWorkItem) {
        scheduledItems.append((now + interval, workItem))
    }

    func advance(by interval: TimeInterval) {
        now += interval
        let dueItems = scheduledItems.filter { $0.time <= now }
        scheduledItems.removeAll { $0.time <= now }
        dueItems.filter { !$0.workItem.isCancelled }.forEach { $0.workItem.perform() }
    }
}

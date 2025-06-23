//
//  Item.swift
//  macSchedule
//
//  Created by KimJunsoo on 6/23/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

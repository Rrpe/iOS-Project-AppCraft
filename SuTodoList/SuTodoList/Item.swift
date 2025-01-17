//
//  Item.swift
//  SuTodoList
//
//  Created by KimJunsoo on 1/17/25.
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

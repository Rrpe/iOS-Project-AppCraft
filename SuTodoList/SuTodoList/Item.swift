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
    var title: String?
    var timestamp: Date
    var isFinish: Bool = false
    
    init(title: String, timestamp: Date, isFinish: Bool) {
        self.title = title
        self.timestamp = timestamp
        self.isFinish = isFinish
    }
}

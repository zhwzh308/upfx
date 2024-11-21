//
//  Item.swift
//  upfx
//
//  Created by Wenzhong Zhang on 2024-11-21.
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

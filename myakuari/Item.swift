//
//  Item.swift
//  myakuari
//
//  Created by chang chiawei on 2025-04-11.
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

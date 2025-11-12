//
//  Item.swift
//  StraightPool
//
//  Created by Craig  on 11/12/25.
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

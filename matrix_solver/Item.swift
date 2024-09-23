//
//  Item.swift
//  matrix_solver
//
//  Created by Rachelle Rosiles on 3/12/24.
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

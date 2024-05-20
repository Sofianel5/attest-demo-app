//
//  Item.swift
//  AttestDemo
//
//  Created by Sofiane Larbi on 5/19/24.
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

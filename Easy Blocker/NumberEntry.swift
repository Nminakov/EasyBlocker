//
//  NumberEntry.swift
//  Easy Blocker
//
//  Created by Nikita Minakov on 12/26/20.
//

import Foundation

struct NumberEntry: Codable {
    var name: String
    var number: Int
    
    init(name: String = "", number: Int) {
        self.name = name
        self.number = number
    }
}

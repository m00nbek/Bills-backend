//
//  ExpenseRequest.swift
//  
//
//  Created by m00nbek Melikulov on 1/27/23.
//

import Foundation

struct ExpenseRequest: Codable {
    let title: String
    let cost: Float
    let currency: String
}

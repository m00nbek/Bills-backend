//
//  PaginatedRequest.swift
//  
//
//  Created by m00nbek Melikulov on 1/27/23.
//

import Foundation

struct PaginatedRequest: Codable {
    var limit: Int?
    var afterId: UUID?
    
    enum CodingKeys: String, CodingKey {
        case limit
        case afterId = "after_id"
    }
}

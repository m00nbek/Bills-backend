//
//  ItemWrapper.swift
//  
//
//  Created by m00nbek Melikulov on 12/4/22.
//

import Vapor

final class ItemWrapper<Element: Encodable>: AsyncResponseEncodable {
    func encodeResponse(for request: Vapor.Request) async throws -> Vapor.Response {
        
        let json = [
            "items": items
        ]
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let items = try encoder.encode(json)
        
        return Vapor.Response(body: .init(data: items))
    }
    
    var items: [Element]
    
    init(items: [Element]) {
        self.items = items
    }
}

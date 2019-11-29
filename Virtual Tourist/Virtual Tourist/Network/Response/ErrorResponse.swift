//
//  ErrorResponse.swift
//  Virtual Tourist
//
//  Created by Abdulla Hasanov on 11/27/19.
//  Copyright © 2019 Abdulla Hasanov. All rights reserved.
//

import Foundation

struct ErrorResponse: Decodable {
    let stat: String
    let code: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case stat = "stat"
        case code = "code"
        case message = "message"
    }
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}

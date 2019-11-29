//
//  SearchResponse.swift
//  Virtual Tourist
//
//  Created by Abdulla Hasanov on 11/27/19.
//  Copyright © 2019 Abdulla Hasanov. All rights reserved.
//

import Foundation

struct SearchResponse: Codable {
    
    var photos: PhotosResponse?
    var stat: String
    
    enum CodingKeys: String, CodingKey {
        case photos = "photos"
        case stat = "stat"
    }
}

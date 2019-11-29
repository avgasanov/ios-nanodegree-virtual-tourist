//
//  PhotosResponse.swift
//  Virtual Tourist
//
//  Created by Abdulla Hasanov on 11/27/19.
//  Copyright © 2019 Abdulla Hasanov. All rights reserved.
//

import Foundation

struct PhotosResponse: Codable {
    
    let page: Int
    let pages: Int
    let photo: Array<PhotoResponse>
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case pages = "pages"
        case photo = "photo"
    }
}

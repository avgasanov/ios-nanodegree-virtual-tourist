//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Abdulla Hasanov on 11/26/19.
//  Copyright © 2019 Abdulla Hasanov. All rights reserved.
//

import Foundation

class FlickrClient {
    
    enum Endpoints {
        static let searchBase = "https://www.flickr.com/services/rest/?method="
        static let apiKey = "148175d9eacca6fdf57c8b9c4ac4548c"
        
        case geosearch(latitude: String, longitude: String, page: Int?)
        case photo(photo: PhotoResponse)
        
        var stringValue: String {
            switch self {
            case .geosearch(let latitude, let longitude, let page):
                var pageParam: String?
                if let page = page {
                    pageParam = "&page=\(page)"
                }
                return Endpoints.searchBase +
                    "flickr.photos.search&api_key=" +
                    Endpoints.apiKey + "&per_page=20&lat=\(latitude)&lon=\(longitude)&format=json&nojsoncallback=1" + (pageParam ?? "")
            case .photo(let photo):
                return "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // Helper function from lessons. Refactored
    class func dataTaskForRequest<ResponseType: Decodable>(method: String = "GET", url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        debugPrint("URL: ", url)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                debugPrint(error)
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
    // Helper function from lessons. Refactored
    class func downloadTaskForRequest(url: URL, completion: @escaping (Data?, Error?) -> Void) -> URLSessionDownloadTask {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location = location else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                let data = try Data(contentsOf: location)
                DispatchQueue.main.async {
                    completion(data, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            
        }
        task.resume()
        return task
    }
    
    class func getPhotoPage(lat: String, lon: String, completion: @escaping (PhotosResponse?, Error?) -> Void) {
        let url = Endpoints.geosearch(latitude: lat, longitude: lon, page: nil).url
        let task = dataTaskForRequest(url: url, responseType: SearchResponse.self) { searchResponse, error in
            if searchResponse?.photos?.photo.count == 0 {
                let error = ErrorResponse(stat: "not ok", code: 404, message: "No photos found")
                completion(nil, error)
                return
            }
            if let pageCount = searchResponse?.photos?.pages {
                if pageCount <= 1 {
                    completion(searchResponse?.photos, nil)
                    return
                }
                let randomPage = Int.random(in: 0 ..< pageCount)
                debugPrint("random page: \(randomPage)")
                let randomUrl = Endpoints.geosearch(latitude: lat, longitude: lon, page: randomPage).url
                let randomTask = dataTaskForRequest(url: randomUrl, responseType: SearchResponse.self) { searchResponse, error in
                    completion(searchResponse?.photos, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
}

//
//  NetworkService.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 12/5/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

import Foundation

class NetworkService {
  private let keyService: KeyService
  
  init(keyService: KeyService) {
    self.keyService = keyService
  }
  private lazy var session: URLSession = {
    return URLSession(configuration: .default)
  }()
  enum NetworkError: Error {
    case urlError
    case httpError(_ statusCode: Int)
    case noData
    case requestError(_ error: Error)
    case parseError
    case improperResponseType
  }
  
  private static var formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()
  
  private static var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()
  
  func getCarResults(startDate: Date, endDate: Date, lat: Double, long: Double, completion: @escaping (CarSearchResults?, Error?) -> Void) {
    let apiKey: String
    do {
      apiKey = try keyService.key(forName: "amadeusAPIKey")
    } catch {
      completion(nil, error)
      return
    }
    let parameters = [
      "apikey": apiKey,
      "latitude": String(describing: lat),
      "longitude": String(describing: long),
      "radius": "40",
      "pick_up": NetworkService.formatter.string(from: startDate),
      "drop_off": NetworkService.formatter.string(from: endDate),
    ]
    
    let request: URLRequest
    do {
      request = try buildRequest(fromURL: "https://api.sandbox.amadeus.com/v1.2/cars/search-circle", parameters: parameters)
    } catch {
      completion(nil, error)
      return
    }

    let session = URLSession(configuration: .default)
    let task = session.dataTask(with: request) { (data, response, error) in
      do {
        let response: CarSearchResults = try self.processResponse(data: data, response: response, error: error)
        DispatchQueue.main.async {
          completion(response, nil)
        }
      } catch {
        DispatchQueue.main.async {
          completion(nil, error)
        }
      }
    }
    task.resume()
  }
  
  func imageData(for url: URL, completion: @escaping (Data?, Error?) -> Void) {
    let request = URLRequest(url: url)
    session.dataTask(with: request) { data, response, error in
      if let error = error {
        completion(nil, error)
        return
      }
      guard let data = data else { completion(nil, NetworkError.noData); return }
      completion(data, nil)
      }.resume()
  }
  
  private func buildRequest(fromURL url: String, parameters: [String: String]?) throws -> URLRequest {
    guard var urlComponents = URLComponents(string: url) else {
      throw NetworkError.urlError
    }
    urlComponents.queryItems = parameters?.map(URLQueryItem.init(name:value:))
    guard let url = urlComponents.url else {
      throw NetworkError.urlError
    }
    return URLRequest(url: url)
  }
  
  private func processResponse<T: Decodable>(data: Data?, response: URLResponse?, error: Error?) throws -> T {
    guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { throw NetworkError.improperResponseType }
    guard statusCode >= 200, statusCode < 300 else { throw NetworkError.httpError(statusCode) }
    guard let data = data else { throw NetworkError.noData }
    if let error = error { throw NetworkError.requestError(error) }
    
    do {
      return try NetworkService.decoder.decode(T.self, from: data)
    } catch {
      print(error.localizedDescription)
      throw NetworkError.parseError
    }
  }
}

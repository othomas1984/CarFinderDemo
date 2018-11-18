//
//  Keys.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 11/18/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

import Foundation

class KeyService {
  enum KeyError: Error {
    case keyError
  }
  
  func key(forName name: String) throws -> String  {
    guard let filePath = Bundle.main.path(forResource: "Keys", ofType: "plist"),
      let plist = NSDictionary(contentsOfFile: filePath) as? [String: Any],
      let key = plist[name] as? String else {
        throw KeyError.keyError
    }
    return key
  }
}

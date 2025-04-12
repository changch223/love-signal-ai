//
//  APIKey.swift
//  myakuari
//
//  Created by chang chiawei on 2025-04-12.
//

import Foundation

enum APIKey {
  static var `default`: String {
    guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist") else {
      fatalError("Couldn't find file 'GenerativeAI-Info.plist'.")
    }
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let value = plist?.object(forKey: "API_KEY") as? String else {
      fatalError("Couldn't find key 'API_KEY' in 'GenerativeAI-Info.plist'.")
    }
    if value.starts(with: "_") || value.isEmpty {
      fatalError("Follow the instructions on how to obtain an API key from Google Cloud.")
    }
    return value
  }
}

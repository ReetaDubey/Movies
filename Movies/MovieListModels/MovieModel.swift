//
//  MovieModel.swift
//  Movies
//
//  Created by Reeta Dubey on 20/07/23.
//

import Foundation
struct MovieModel: Decodable {
    var name: String?
    var posterImage: String
    
    private enum Key: String, CodingKey {
        case name = "name"
        case posterImage = "poster-image"
    }

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: Key.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.posterImage = try container.decode(String.self, forKey: .posterImage)
    }
}

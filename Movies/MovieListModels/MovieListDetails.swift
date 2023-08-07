//
//  MovieListDetails.swift
//  Movies
//
//  Created by Reeta Dubey on 20/07/23.
//

import Foundation
struct MovieListDetails: Decodable {
    var title: String?
    var totalContentItems: Int?
    var pageNum: Int?
    var pageSize: Int?
    var contentItems: [MovieModel]?

    private enum PageKey: String, CodingKey {
        case page = "page"
    }
    
    private enum PageDetailsKey: String, CodingKey {
        case page = "page"
        case title = "title"
        case totalContentItems = "total-content-items"
        case pageNum = "page-num"
        case pageSize = "page-size"
        case contentItems = "content-items"
    }
    
    private enum ContentKey: String, CodingKey {
        case content = "content"
    }
    
    init(from decoder: Decoder) throws {
        let pageContainer = try decoder.container(keyedBy: PageKey.self)
        
        let contentContainer =  try pageContainer.nestedContainer(keyedBy: PageDetailsKey.self, forKey: .page)
        self.title = try contentContainer.decode(String.self, forKey: .title)
        self.totalContentItems = (try contentContainer.decode(String.self, forKey: .totalContentItems)).codingKey.intValue
        self.pageNum = try contentContainer.decode(String.self, forKey: .pageNum).codingKey.intValue
        self.pageSize = try contentContainer.decode(String.self, forKey: .pageSize).codingKey.intValue
        
        let listContainer = try contentContainer.nestedContainer(keyedBy: ContentKey.self, forKey: .contentItems)
        self.contentItems = try listContainer.decode([MovieModel].self, forKey: .content)
    }
    
    mutating func updateList(with list: [MovieModel]) {
        self.contentItems?.append(contentsOf: list)
    }
}
